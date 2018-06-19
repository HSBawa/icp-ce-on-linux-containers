#!/bin/bash
tabs 2
spaces=" "
node_image_name=glusterfs-server-base-v2
profiles="-p default -p glusterfs-server-"
node_count=2
node_start_index=1
net_bridge=lxdbr0
net_iface=eth0
## Change below to get subnet info dynamically
node_ip_pre=10.71.17.
start_ip=190
node_name_pre=glusterfs-server-
fstab=/etc/fstab
hosts=/etc/hosts
volumes=10
data_pre=/volume/data
pool_pre=/volume/pool
vol_pre=vol
vol_count=10

node_end_index=$((($node_start_index+$node_count)-1))
#cluster="abc:/dummy efg:/dummy"
#cluster="${cluster//dummy/real}"
#echo $cluster
#exit

function restart(){
    servers=$(lxc list $node_name_pre -c n --format=csv)
    servers=${servers//$'\n'/  } # Repalce newlines with spaces
    echo "Ready to restart [$servers] in 5 secs. Press Ctrl-C to cancel."
    sleep 5
    echo -n "Restarting ... "
    lxc restart $servers
    sleep 10
    #echo "Done"
}

function stop_servers(){
  servers=$(lxc list $node_name_pre -c n --format=csv)
  servers=${servers//$'\n'/  } # Repalce newlines with spaces
  if [ ! -z "$servers" ]; then
    echo "Ready to stop [$servers] in 5 secs. Press Ctrl-C to cancel."
    sleep 5
    echo -e "\tStopping ... "
    lxc stop $servers
    echo ""
  else
      echo "No glusterfs servers to stop"
  fi
  echo ""
}

function start_servers(){
  servers=$(lxc list $node_name_pre -c n --format=csv)
  servers=${servers//$'\n'/  } # Repalce newlines with spaces
  echo "Starting [$servers] now ..."
  lxc start $servers
  #echo "Done"
  echo ""
}


function settle_down(){
    echo -n "Waiting for servers to settle down ... "
    sleep $1
    echo ""
}

########################################################################
## Delete existing Profiles
########################################################################
function delete_glusterfs_profiles(){
    for i in $(seq $node_start_index $node_end_index)
    do
      echo "i = $i"
      profile_name=$node_name_pre$i
      profile_exists=$(lxc profile list | grep $profile_name)
      if [ ! -z "$profile_exists" ]; then
          echo "Deleting  profile $profile_name"
          lxc profile delete $profile_name
      fi
    done
}

########################################################################
## Create new profiles from yaml files
########################################################################
function create_glusterfs_profiles(){
    for i in $(seq $node_start_index $node_end_index)
    do
      profile_name=$node_name_pre$i
      profile_exists=$(lxc profile list | grep $profile_name)
      if [ -z "$profile_exists" ]; then
          echo "Creating profile [$profile_name] ..."
          lxc profile create $profile_name
          cat glusterfs-server-$i.yaml| lxc profile edit $profile_name
      else
          echo "Profile $profile_name already exists"
      fi
    done
}

########################################################################
## Stop and Delete existing Gluster FS Server
## TODO : Need to automate server name pull and delete
########################################################################
function delete_servers(){
  servers=$(lxc list $node_name_pre -c n --format=csv)
  servers=${servers//$'\n'/  } # Repalce newlines with spaces
  echo ""
  if [ ! -z "$servers" ]; then
      echo "Ready to delete  exiting [$servers] in 5 secs. Press Ctrl-C to cancel."
      sleep 5
      echo -ne "\tDeleting ... "
      lxc delete $servers &> /dev/null
      #echo "Done"
  else
      echo "No glusterfs servers to delete"
  fi

  ## Clean up profiles too
  delete_glusterfs_profiles
  echo ""
}



########################################################################
## Create gluster fs server
## Use Ubuntu 16:04 for now. 17.10 get glusterfs server install errors.
########################################################################

function create_server(){
  ip=$node_ip_pre$((($start_ip+$2)-1))
  node_name=$node_name_pre$1

  echo "[$node_name]"
#    lxc init ubuntu: $gfs$i  -c security.nesting=true -c security.privileged=true &> /dev/null
  lxc init $profiles$1 $node_image_name $node_name -c security.privileged=true -c security.nesting=true
  #echo "Done"
  echo -e "\tattaching $net_bridge ... "
  lxc network attach $net_bridge $node_name eth0
  #echo "Done"
  echo  -e "\tassigning IP address $ip to $node_name node ... "
  lxc config device set $node_name $net_iface ipv4.address $ip
  #echo "Done"
  echo  -e "\tupdating config"
  lxc config set $node_name security.privileged true
  lxc config set $node_name security.nesting true
  echo "  "
}

########################################################################
## Create gluster fs server
## Use Ubuntu 16:04 for now. 17.10 get glusterfs server install errors.
########################################################################

function create_servers(){
    create_glusterfs_profiles
    counter=1
    for i in $(seq $node_start_index $node_end_index)
    do
      create_server $i $counter
      counter=$(($counter+1))
    done
    start_servers
}

function update_software(){
    #######################################################
    ## Install needed software in containers
    #######################################################

    for i in $(seq $node_start_index $node_end_index)
    do
      node_name=$node_name_pre$i
      echo "Updating software on nodes: "
      echo "[$node_name]"
      lxc exec $node_name -- sh -c "apt-get update"
      echo ""
      echo "Installing glusterfs-server: "
      lxc exec $node_name -- sh -c "add-apt-repository -y -u ppa:gluster/glusterfs-3.13"
      echo ""
      lxc exec $node_name -- sh -c "apt-get update"
      echo ""
      lxc exec $node_name -- sh -c "apt -y install glusterfs-server"
      echo ""
    done
}

function update_hosts(){

  ## for each node update hosts file
  for i in $(seq $node_start_index $node_end_index)
  do
    node_name=$node_name_pre$i
    echo "Updating hosts files:"
    echo "[$node_name_pre$i]"
    lxc exec $node_name -- sh -c "echo $spaces >> $hosts"
    ## Update current nodes hosts file with all glusterfs servers name and ip address
    for j in $(seq $node_start_index $node_end_index)
    do
       node_name_temp=$node_name_pre$j
       echo "Retrieving IP sddress for node $node_name_temp"
       temp_ip="$(lxc exec $node_name_temp -- ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)"
       echo "Adding $temp_ip $node_name_temp to $node_name hosts file."
       lxc exec $node_name -- sh -c "echo $temp_ip $node_name_temp >> $hosts"
    done
    lxc exec $node_name -- sh -c "echo $spaces >> /etc/hosts"
  done
}

function peer_probe(){
    ########################################################
    ## Peer probe From Server 2: gluster peer probe glusterfs-server1
    ## Peer probe From Server 1: gluster peer probe glusterfs-server2
    ########################################################
    echo  "Executing gluster-fs peer probe:"
    for i in $(seq $node_start_index $node_end_index)
    do
      node_name=$node_name_pre$i
      for j in $(seq $node_start_index $node_end_index)
      do
         node_name_temp=$node_name_pre$j
         if [[ "$node_name" != "$node_name_temp" ]]; then
           echo "Peer probe $node_name -> $node_name_temp"
           lxc exec $node_name gluster peer probe $node_name_temp
         fi
      done
    done
}

function peer_status(){
  echo  "Executing gluster-fs peer status:"
  for i in $(seq $node_start_index $node_end_index)
  do
    node_name=$node_name_pre$i
    lxc exec $node_name gluster peer status
  done
}

function create_volumes(){
    echo "Creatng volumes: "

    ########################################################
    ## Create Folder and Volumes
    ########################################################
    dummy="dummy_data_folder"

    ## Gather cluster info for vol creation
    echo "Gathering cluster info: "
    cluster=""
    for i in $(seq $node_start_index $node_end_index)
    do
      node_name=$node_name_pre$i
      cluster="$cluster $node_name:$dummy "
    done

    ## Create data (manager) and pool (mount) folders (for each volume) on each node
    for i in $(seq $node_start_index $node_end_index)
    do
      node_name=$node_name_pre$i
      echo "[$node_name]"
      for j in $(seq 1 $vol_count)
      do
        echo "Creating folder $data_pre$j on $node_name"
        lxc exec $node_name mkdir $data_pre$j
        echo "Creating folder$pool_pre$j on $node_name"
        lxc exec $node_name mkdir $pool_pre$j
      done
    done

    ## Create volumes
    vol_node_name=$node_name_pre$node_start_index
    for i in $(seq $node_start_index $node_end_index)
    do
      node_name=$node_name_pre$i
      echo ""
      echo "[$node_name]"
      for j in $(seq 1 $vol_count)
      do
        if [[ "$vol_node_name" == "$node_name" ]]; then
          ## Replace dummy folder name with actual data folder name
          echo "Creating volume $vol_pre$j on $vol_node_name"
          echo "vol = $vol_pre$j, data=$data_pre$j"
          echo "Executing: lxc exec $node_name gluster volume create $vol_pre$j replica 2 transport tcp ${cluster//$dummy/$data_pre$j} force"
          lxc exec $node_name gluster volume create $vol_pre$j replica 2 transport tcp ${cluster//$dummy/$data_pre$j} force
         # else
          echo "Starting volume $vol_pre$j on $node_name"
          echo "Executing: lxc exec $node_name gluster volume start $vol_pre$j"
          lxc exec $node_name gluster volume start $vol_pre$j
        fi
      done
    done
    #echo "Done"
    echo ""
}


function mount_volumes(){
    ### If fuse error during mount and id ls /dev/fuse does not exist,
    ### create one in both containers. Try mount again after restart.
    ### See following command: sudo mknod /dev/fuse c 10 229
    ### Mounting on external server (consumer/client)
    ### Ex:  mount -t glusterfs server1:/gv0 /mnt
    ###for i in `seq -w 1 100`; do cp -rp /var/log/messages /mnt/copy-test $i; done
      echo  "Mounting volumes "
      node_name=$node_name_pre$node_start_index
          for j in $(seq 1 $vol_count)
      do
        echo "Mounting $pool_pre$j' ... "
        lxc exec $node_name -- mount $pool_pre$j
        #echo "Done"
      done
      #echo "Done"
}

function update_fstab(){
  ## for each node update hosts file
  vol_node_name=$node_name_pre$node_start_index
  echo "Updating fstab files:"
  for i in $(seq $node_start_index $node_end_index)
  do
    node_name=$node_name_pre$i
    echo "Updating node : $node_name_pre$i ... "
    lxc exec $node_name -- sh -c "echo $spaces >> $fstab"
    lxc exec $node_name -- sh -c "echo ### Gluster FS Volume >> $fstab"
    for j in $(seq 1 $vol_count)
    do
      echo "Updating volume : $vol_pre$j ... "
      lxc exec $node_name -- sh -c "echo $vol_node_name:/$vol_pre$j $pool_pre$j glusterfs defaults,_netdev 0 0  >> $fstab"
      #echo "Done"
    done
    lxc exec $node_name -- sh -c "echo $spaces >> $fstab"
    lxc exec $node_name -- sh  -c "mount -a"
    #echo "Done"
  done
  #echo "Done"
}

function volume_info(){
  echo "Getting volume info:"
  for i in $(seq $node_start_index $node_end_index)
  do
    node_name=$node_name_pre$i
    echo "$node_name_pre$i ... "
    lxc exec $node_name gluster volume info
  done
  #echo "Done"
}


function verify_mount(){

  echo "Verifying mount :"
  for i in $(seq $node_start_index $node_end_index)
  do
    node_name=$node_name_pre$i
    echo "Node: $node_name_pre$i ... "
    for j in $(seq 1 $vol_count)
    do
      echo "Pool : $pool_pre$j ... "
      lxc exec $node_name -- sh -c "df -h $pool_pre$j"
        #echo "Done"
    done
    #echo "Done"
  done
  #echo "Done"
}

function view_fstab(){
  echo "Getting Fstab info:"
  for i in $(seq $node_start_index $node_end_index)
  do
    node_name=$node_name_pre$i
    echo "[$node_name_pre$i] - $fstab"
    lxc exec $node_name -- sh -c "cat $fstab"
    echo "Done"
    echo ""
  done
}

function test_vols(){
    for i in $(seq 1 $vol_count)
    do
        mount -t glusterfs server1:/vol$vol_count /mnt
        for j in {1..3}
        do
            cp -rp /var/log/messages /mnt/test-vol$i-$j;
        done
    done
}

list_profiles(){
  lxc profile list | grep $node_name_pre
}


list_servers(){
    lxc list $node_name_pre
}

function create_cluster(){
    echo ""
    echo "**********************************[Stop Servers]**********************************"
    stop_servers
    echo ""

    echo "**********************************[Delete Servers]**********************************"
    delete_servers
    echo ""

    ###### Initialize Servers
    echo "**********************************[Create Servers]**********************************"
    create_servers
    echo ""

    ###### Wait for servers to settle down ... especial
    settle_down 20
    echo ""

    ###### Update platform and install glusterfs servers
    echo "**********************************[Update Software ]**********************************"
    #update_software
    echo ""

    echo "**********************************[Update Hosts]**********************************"
    update_hosts
    echo ""

    echo "**********************************[Peer Probe]**********************************"
    peer_probe
    echo ""

    echo "**********************************[Peer Status]**********************************"
    peer_status
    echo ""

    echo "**********************************[Create Volumes]**********************************"
    create_volumes
    echo ""

    echo "**********************************[Volume Info]**********************************"
    volume_info
    echo ""

    echo "**********************************[Update Fstab]**********************************"
    update_fstab
    echo ""

    echo "**********************************[Mount Volumes]**********************************"
    #mount_volumes
    echo ""

    echo "**********************************[Restart Servers]**********************************"
    restart
    echo ""

    echo "**********************************[Verify Mount]**********************************"
    verify_mount
    echo ""

    echo "**********************************[View fstab]**********************************"
    #view_fstab
    echo ""

    echo "**********************************[List GlusterFS Profiles]**********************************"
    list_profiles
    echo ""

    echo "**********************************[List GlusterFS Servers]**********************************"
    list_servers
    echo ""

    exit


}

function verify(){
    echo ""
    echo "**********************************[Peer Probe]**********************************"
    peer_probe
    echo ""

    echo "**********************************[Peer Status]**********************************"
    peer_status
    echo ""

    echo "**********************************[Volume Info]**********************************"
    volume_info
    echo ""

    echo "**********************************[Verify Mount]**********************************"
    #verify_mount
    echo ""

    echo "**********************************[View fstab]**********************************"
    #view_fstab
    echo ""
}

create_cluster
verify
