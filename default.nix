{
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "vmm-reference";
  version = "0.1.0";

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "linux-loader-0.4.0" = "sha256-o9hLvHqROSCWT1vUk0x5T22IVhqQ13r64V7d8n+CAxs=";
      "virtio-blk-0.1.0" = "sha256-4jivDWpsTu/sT27iWnMN/YQHECIHFBshikGrp3dcZ0w=";
    };
  };

  meta = with lib; {
    homepage = "https://github.com/rust-vmm/vmm-reference";
    description = "A reference VMM using Rust-VMM";
    license = with licenses; [bsd3 asl20];
    maintainers = [
      {
        email = "aleksey.makarov@gmail.com";
        github = "aleksey-makarov";
        githubId = 19228987;
        name = "Aleksei Makarov";
      }
    ];
    platforms = ["x86_64-linux"];
  };
}
