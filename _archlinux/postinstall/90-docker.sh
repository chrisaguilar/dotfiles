title "Docker Setup"


subtitle "Installing Packages"
package_install "docker"


subtitle "Adding user to docker group"
add_to_group "docker"


subtitle "Enabling Docker"
enable_services "docker.service"
