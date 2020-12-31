# Jenkins Dynamic DropDown

### This Script will get Kubernetes Cluster Namespaces names (by zones) and add to Job DropDown menu

- Prepare in the script:
```bash
$ cd /var/lib
$ git clone https://github.com/graypit/Jenkins-Dynamic-DropDown.git
$ chmod +x jenkins-dynamic-dropdown/DynamicDropDown.sh
```
- Add your Kubernetes config files to `jenkins-dynamic-dropdown/kubeconfigs/` using zone folders (Aws/Azure and so on)
- Add to crontab for every 2min:
```bash
$ crontab -e
*/2 * * * * cd /var/lib/jenkins-dynamic-dropdown && timeout 1m ./DynamicDropDown.sh
```
Copyright &copy; 2020 Habib Guliyev
