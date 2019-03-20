[Specifying your own certificate authority (CA) for IBM Cloud Private Services](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/installing/create_ca_cert.html) <br>

* Place your icp-router.csr and icp-router.key files in this folder  <br>
   * Creating your own self signed key and certs:
      * openssl genrsa -out icp-router.key 4096
      * openssl req -new -key icp-router.key -out icp-router.csr -subj "/CN=mycluster.icp"
   * You can BYOK (Bring Your Own Key) to use inside your IBM Cloud Private cluster. <br>
      * Your BYOK certificate key must be exported in ** PEM ** (OpenSSL) format. <br>
