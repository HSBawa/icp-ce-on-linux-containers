### Update LXD config examples ###
----
**Get HTTPS address:port**
 * lxc config get core.https_address


**Change HTTPS address:port**
  * lxc config set core.https_address [::]:10443
  * lxc config set core.https_address xxx.xxx.xxx.xxx:10443  


**Set HTTPS password**
   * lxc config set core.trust_password &lt;new password&gt;

**Unset HTTPS password**   
   * lxc config set core.trust_password  ""

**Check if password is set**
  * lxc config get core.trust_password
    * 'true', if set

**For more config options:**
* lxc config set &lt;TAB TAB&gt;

        backups.compression_algorithm,  cluster.offline_threshold       core.https_allowed_headers      core.proxy_https                dev-worker-0                    images.compression_algorithm    maas.machine
        candid.api.url                  core.debug_address              core.https_allowed_methods      core.proxy_ignore_hosts         dev-worker-1                    images.remote_cache_expiry      
        candid.domains                  core.https_address              core.https_allowed_origin       core.trust_password             images.auto_update_cached       maas.api.key                    
        candid.expiry                   core.https_allowed_credentials  core.proxy_http                 dev-master-0                    images.auto_update_interval     maas.api.url                    

* lxc config get &lt;TAB TAB&gt;

        backups.compression_algorithm,  cluster.offline_threshold       core.https_allowed_headers      core.proxy_https                dev-worker-0                    images.compression_algorithm    maas.machine
        candid.api.url                  core.debug_address              core.https_allowed_methods      core.proxy_ignore_hosts         dev-worker-1                    images.remote_cache_expiry      
        candid.domains                  core.https_address              core.https_allowed_origin       core.trust_password             images.auto_update_cached       maas.api.key                    
        candid.expiry                   core.https_allowed_credentials  core.proxy_http                 dev-master-0                    images.auto_update_interval     maas.api.url                    
