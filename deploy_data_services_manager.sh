#!/bin/bash
# Author: William Lam

OVFTOOL="/Applications/VMware OVF Tool/ovftool"
DSM_OVA="/Volumes/Storage/Software/VCF9/PROD/COMP/DSM/dsm-va-9.0.0.0.24713720.ova"

# Check if ovftool exists and is executable
if [[ ! -x "$OVFTOOL" ]]; then
    echo "ovftool not found or is not executable: $OVFTOOL"
    exit 1
fi

# Check if the OVA file exists
if [[ ! -f "$DSM_OVA" ]]; then
    echo "VCF Installer OVA not found: $DSM_OVA"
    exit 1
fi

VC_HOST="vc01.vcf.lab"
VC_USERNAME="administrator@vsphere.local"
VC_PASSWORD='VMware1!VMware1!'
VM_NETWORK="DVPG_FOR_VM_MANAGEMENT"
VM_DATASTORE="vsanDatastore"
VM_DATACENTER="VCF-Datacenter"
VM_CLUSTER="VCF-Mgmt-Cluster"

DSM_VMNAME=dsm01
DSM_HOSTNAME=dsm01.vcf.lab
DSM_IP=172.30.0.50
DSM_SUBNET=255.255.255.0
DSM_GATEWAY=172.30.0.1
DSM_DNS_SERVER=192.168.30.29
DSM_NTP=104.167.215.195
DSM_ROOT_PASSWORD='VMware1!VMware1!'

### DO NOT EDIT BEYOND HERE ###

VC_THUMBPRINT=$(echo | openssl s_client -connect ${VC_HOST}:443 2>/dev/null | openssl x509 -noout -fingerprint -sha256 | cut -d= -f2)

echo -e "\nDeploying Data Services Manager ${DSM_VMNAME} ..."
"${OVFTOOL}" --acceptAllEulas --noSSLVerify --skipManifestCheck --X:injectOvfEnv --allowExtraConfig --X:waitForIp --sourceType=OVA --powerOn \
"--net:Management Network=${VM_NETWORK}" --datastore=${VM_DATASTORE} --diskMode=thin --name=${DSM_VMNAME} \
"--prop:vami.dnsnames.DMS_Provider_VA=${DSM_HOSTNAME}" \
"--prop:vami.ip0.DMS_Provider_VA=${DSM_IP}" \
"--prop:vami.netmask0.DMS_Provider_VA=${DSM_SUBNET}" \
"--prop:vami.gateway.DMS_Provider_VA=${DSM_GATEWAY}" \
"--prop:vami.DNS.DMS_Provider_VA=${DSM_DNS_SERVER}" \
"--prop:vami.ntp.DMS_Provider_VA=${DSM_NTP}" \
"--prop:guestinfo.cis.appliance.provider.password=${DSM_ROOT_PASSWORD}" \
"--prop:guestinfo.cis.appliance.provider.vc_host=${VC_HOST}" \
"--prop:guestinfo.cis.appliance.provider.vc_thumbprint=${VC_THUMBPRINT}" \
"--prop:guestinfo.cis.appliance.provider.vc_username=${VC_USERNAME}" \
"--prop:guestinfo.cis.appliance.provider.vc_password=${VC_PASSWORD}" \
${DSM_OVA} "vi://${VC_USERNAME}:${VC_PASSWORD}@${VC_HOST}/${VM_DATACENTER}/host/${VM_CLUSTER}"
