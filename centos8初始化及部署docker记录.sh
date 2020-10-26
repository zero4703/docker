centos 7 和 8  区别
https://www.zhzz.org/asp/2667
 --【firewalld后端从iptables改为nftables，centos8依然支持iptables-service,但后端其实也是nftables】
 --【yum(yum3.4.3)改为dnf（yum4.0.9），日常使用无影响，yum现在只是dnf的软链，命令一样】
 --【只使用Chronyd，不支持NTP部署，因此同步时间需修复chronyd服务/etc/chrony.conf  chronyd.service】
 --【Nftables说明】
https://wiki.archlinux.org/index.php/Nftables_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)



1、按需【更新内核版本】
Import the public key:
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
crntos 8
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

（在 ELRepo 中有两个内核选项，一个是 kernel-lt(长期支持版本)，一个是 kernel-ml(主线最新版本)，采用长期支持版本(kernel-lt)，更稳定一些）
查看可用的系统内核安装包：
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
bpftool.x86_64 5.7.7-1.el8.elrepo elrepo-kernel
kernel-ml-devel.x86_64 5.7.7-1.el8.elrepo elrepo-kernel
kernel-ml-doc.noarch 5.7.7-1.el8.elrepo elrepo-kernel
kernel-ml-headers.x86_64 5.7.7-1.el8.elrepo elrepo-kernel
kernel-ml-modules-extra.x86_64 5.7.7-1.el8.elrepo elrepo-kernel
kernel-ml-tools.x86_64 5.7.7-1.el8.elrepo elrepo-kernel
kernel-ml-tools-libs.x86_64 5.7.7-1.el8.elrepo elrepo-kernel
kernel-ml-tools-libs-devel.x86_64 5.7.7-1.el8.elrepo elrepo-kernel
perf.x86_64 5.7.7-1.el8.elrepo elrepo-kernel
python3-perf.x86_64 5.7.7-1.el8.elrepo elrepo-kernel

安装最新版内核
yum --enablerepo=elrepo-kernel install kernel-ml -y

#设置以新的内核启动【无需操作】
#0 表示最新安装的内核，设置为 0 表示以新版本内核启动：
#$ grub2-set-default 0
重启并检查

查看系统中已安装的内核
可以看到这里一共安装了3个版本的内核，分别是 v4.18.0-193.6.3 和 v4.18.0-147.5.1以及 v5.7.7-1。
$ rpm -qa | grep kernel

[按需] -- {
除旧内核，这一步是可选的。
$ yum remove kernel-core-4.18.0 kernel-devel-4.18.0 kernel-tools-libs-4.18.0 kernel-headers-4.18.0

再查看系统已安装的内核，确认旧内核版本已经全部删除：
$ rpm -qa | grep kernel

也可以安装 yum-utils 工具，当系统安装的内核大于3个时，会自动删除旧的内核版本：
$ yum install yum-utils

删除旧的版本使用 package-cleanup 命令。
}

2、【更新yun源】
yum install wget
华为
wget https://repo.huaweicloud.com/repository/conf/CentOS-8-reg.repo
阿里  【出口网关有问题导致无法正常使用】
 http://mirrors.aliyun.com/repo/Centos-8.repo
刷新yum缓存。
$ yum makecache

【按需】安装tab命令补全、其他工具、修改主机名等
yum -y install bash-completion
source /etc/profile.d/bash_completion.sh
yum install nslookup wget gcc gcc-c++ openssl libssl-dev libxml2 
/etc/resolv.conf 谷歌dns  223.5.5.5  223.6.6.6
hostnamectl set-hostname xxx
优化【.bashrc 】
PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[36;40m\]\w\[\e[0m\]]\$ "


3、【安装iptables】
yum install iptables-services
初始化规则
iptables -A INPUT -s 10.37.0.0/16 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT 
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT 
iptables -A INPUT  -p icmp -j ACCEPT
service iptables save
systemctl start iptables.service 

* 查看服务状态
systemctl list-units
systemctl list-units |grep running
systemctl list-units |grep iptables
systemctl list-units |grep "active exited"

[按需] -- 禁用ipv6 
vi /etc/default/grub 
GRUB_CMDLINE_LINUX=  添加  ipv6.disable=1 
应用新的配置：使用grub2-mkconfig 生成新的grub引导文件
grub2-mkconfig -o /boot/grub2/grub.cfg 
重启验证
[按需] -- [核参数优化/etc/sysctl.conf  和 /etc/security/limits.conf ]
执行应用配置  sysctl -p
【sysctl.conf】
net.ipv4.ip_forward = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 3
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_retries2 = 3
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.core.wmem_default = 262144
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.somaxconn = 262144
net.core.netdev_max_backlog = 256000
net.ipv4.ip_local_port_range = 9000 65500
fs.aio-max-nr = 1048576
fs.file-max = 6815744
#kernel.sysrq = 1

【limits.conf】
*               hard    nofile          204800
*               soft    nofile          65536
*               soft    core            0
*               hard    core            0

[按需] -- 关闭 selinux
# getenforce 
# setenforce 0
vi /etc/selinux/config 
SELINUX=disabled



4、【同步时区】
   --  CentOS 8中已经无法安装ntpdate，因此无法直接使用ntpdate
修改时区
timedatectl list-timezones
timedatectl set-timezone Asia/Shanghai

# vi /etc/chrony.conf 
pool n.pool.ntp.org iburst
#pool 2.centos.pool.ntp.org iburst
server n.pool.ntp.org iburst
server ntp.aliyun.com iburst
重新加载配置
···
systemctl restart chronyd.service
···
时间同步
chronyc sources -v
systemctl enable chronyd.service


5. 【安装 docker-ce】
第一步就是安装 Docker  repo
【官方，比较慢】https://download.docker.com/linux/centos/docker-ce.repo
【阿里】http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
【华为】https://mirrors.huaweicloud.com/docker-ce/linux/centos/docker-ce.repo
执行命令如下：
$ dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
或
$ wget http...  -O /etc/yum.repos.d/docker-ce.repo
显示可用版本
$ dnf list docker-ce --showduplicates
可以看到，截至目前，最新版已经到了 19.03.13
## 安装Docker
yum -y install docker-ce 

[按需] -- 手动安装依赖【新版本已集成】
要想安装 docker-ce 必须事先要安装好依赖 containerd.io，这里就是和 CentOS 7 下自动安装的最大区别。点击这里，查看最新版的 containerd.io。适当地替换下面命令里的下载链接。
执行如下命令：
$ dnf install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.2.el7.x86_64.rpm
再执行安装 Docker
执行如下命令，注意其中有个 --nobest 选项：
$ dnf install -y --nobest docker-ce

启动 Docker
上一步正确安装以后，接下来就要启动 Docker，并设置开机自启动。
启动 Docker 命令：
$ systemctl start docker
查看 Docker 状态：
$ systemctl status docker
设置开机自启动 Docker 命令：
$ systemctl enable docker
查看 Docker 版本信息：
$ docker version


# 配置Docker镜像加速器
vi /etc/docker/daemon.json 
{
    "registry-mirrors": [
            "https://tueulghe.mirror.aliyuncs.com",
            "https://registry.docker-cn.com",
            "http://hub-mirror.c.163.com",
            "https://docker.mirrors.ustc.edu.cn"
        ]
}

# 重新载入配置
systemctl daemon-reload      
systemctl restart docker    

6. 【安装 docker-compose】

【利用 pip3 来安装、或者直接下载github最新版本】
事先安装好 pip3 是必要的，如果本机没有安装，执行如下命令安装 pip3。
$ dnf install -y python3-pip
查看 pip3 版本信息：
$ pip3 --version
返回值：
pip 9.0.3 from /usr/lib/python3.6/site-packages (python 3.6)
安装 docker-compose 命令
$ pip3 install docker-compose
查看 docker-compose 版本信息：
$ docker-compose --version
返回值：
docker-compose version 1.26.2, build unknown


【直接下载github最新版本，虚拟机下载比较慢...】
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 
chmod +x /usr/local/bin/docker-compose
docker-compose -v

7、【最后】
如果系统开启了 firewalld，那么也许需要放行一下 Docker 的网卡才能正常使用网络。
执行命令：
$ firewall-cmd --permanent --zone=trusted  --add-interface=docker0
$ firewall-cmd --reload
注意这里的 Docker 的网卡名为 docker0。一般情况下都是这个名称，不过在此之前最好还是通过 ifconfig 命令来确认一下。