{
  description = "emacs for nix";

  inputs = {
    nixpkgs.url     = github:NixOS/nixpkgs/d9d87c51; # nixos-24.11 2024-12-11
    flake-utils.url = github:numtide/flake-utils/c0e246b9;
    hpkgs1.url      = github:sixears/hpkgs1/r0.0.37.0;
    myPkgs          = {
      url    = github:sixears/nix-pkgs/r0.0.13.0;
#      url    = path:/home/martyn/nix/pkgs;
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs = { self, nixpkgs, flake-utils, hpkgs1, myPkgs }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system:
      let
        pkgs    = nixpkgs.legacyPackages.${system};
        hpkgs   = hpkgs1.packages.${system};
        hlib    = hpkgs1.lib.${system};
        my-pkgs = myPkgs.packages.${system};

        # -- emacs ---------------------

        emacs-with-packages =
          hlib.nixpkgs.emacs.pkgs.emacsWithPackages (ps: with ps; [
            # lsp/haskell-nix:
            # https://thomasbach.dev/posts/2021-08-26-nixos-haskell-emacs-lsp.html
            babel
            company
            dap-mode
            direnv
            fira-code-mode # https://github.com/tonsky/FiraCode/wiki/Emacs-instructions
            flycheck
            flycheck-haskell
            fontawesome
            haskell-mode
            haskell-unicode-input-method
            iedit
            ivy
            ligature
            lsp-haskell
            lsp-mode
            lsp-treemacs
            lsp-ui
            markdown-mode
            mmm-mode
            nix-mode
            org-babel-eval-in-repl
            ## requires 'descriptive' package, which is marked as broken and
            ## even pre-broken does not compile with ghc9
            # structured-haskell-mode
            swiper
            yaml-mode
            yasnippet

            tuareg # an ocaml mode

            # used for liquid mode
            popup button-lock pos-tip flycheck-color-mode-line
            # flycheck-liquidhs.el

            pkgs.git

            hlib.nixpkgs.haskellPackages.cabal-install
            hlib.nixpkgs.haskellPackages.ghc
            hlib.nixpkgs.haskellPackages.hlint
#                hlib.nixpkgs.haskellPackages.stack
#                hlib.nixpkgs.haskellPackages.stylish-haskell
          ]);
      in
        rec {
          packages = flake-utils.lib.flattenTree (with pkgs; {
            emacs = emacs-with-packages;
            emacs-server =
              import ./src/emacs-server.nix {
                inherit pkgs emacs-with-packages;
                inherit (my-pkgs) paths;
              };
          });
        }
    );
}
