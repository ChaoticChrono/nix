# hehe this is hell I hate it <.-.>
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = ["nvidia" "i915" "nvidia_modeset" "nvidia_drm" ];
  boot.kernelModules = [ "kvm-intel" "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    acpi_call
  ];
  boot.initrd.luks = {
  devices = {
    swap = {
      device = "/dev/disk/by-uuid/fe5c81c8-f53d-4934-83ba-6421d8501afa";
      name = "swap";
    };
    root = {
      device = "/dev/disk/by-uuid/94135171-638f-4686-b68b-2376ec892c2b";
      name = "root";
     };
    };
   };
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9e6f7abb-62f4-4b9e-927e-c7be1dc51831";
      fsType = "ext4";
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3A2E-DE52";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  swapDevices =
    [ { device = "/dev/disk/by-uuid/baf1def2-55a7-4d36-9d15-75ca8e1bfbca"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  #networking.interfaces.enp12s0.useDHCP = lib.mkDefault true;
  #networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
