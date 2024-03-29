virt-install \
--name centos \
--memory 512 \
--vcpus=1 \
--disk path=/data/images/kvm_centos.img,size=10 \
--network bridge=br0 \
--cdrom=/data/iso/CentOS-7-x86_64-Minimal-2003.iso \
--accelerate \
--graphics vnc,listen=0.0.0.0 \
--os-type=linux \
--os-variant=rhel7.6
