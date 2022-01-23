{
  description = "A pass extension for managing one-time-password (OTP) tokens";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        defaultPackage = with pkgs; stdenv.mkDerivation {
          pname = "pass-otp";
          version = "unstable";
          src = ./.;

          buildInputs = [ oathToolkit ];

          checkInputs = [
            bash
            expect
            git
            gnumake
            gnupg
            pass
            shellcheck
            which
          ];

          dontBuild = true;
          doCheck = true;

          patchPhase = ''
            sed -i -e 's|OATH=\$(which oathtool)|OATH=${oathToolkit}/bin/oathtool|' otp.bash
          '';

          checkPhase = ''
            make SHELL=$SHELL check
          '';

          installFlags = [
            "PREFIX=$(out)"
            "BASHCOMPDIR=$(out)/share/bash-completions/completions"
          ];

          meta = with lib; {
            description = "A pass extension for managing one-time-password (OTP) tokens";
            homepage = "https://github.com/tadfisher/pass-otp";
            license = licenses.gpl3;
            maintainers = with maintainers; [ tadfisher ];
            platforms = platforms.unix;
          };
        };

        checks.pass-otp = self.defaultPackage.${system};
      }
    );
}
