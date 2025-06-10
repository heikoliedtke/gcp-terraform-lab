To install Terraform on Debian 12 (Bookworm), the most reliable and recommended method is to use the official HashiCorp APT repository. This ensures you get the latest stable versions and simplifies future updates.


sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl


curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg


echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list


sudo apt-get update && sudo apt-get install terraform


terraform --version


