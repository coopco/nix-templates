{
  descriptions = "A personal collection of flake templates";

  outputs = { self }: {
    python = {
      path = ./python;
      description = "Python template, using poetry2nix";
      welcomeText = ''
        # Getting started
        - Run `direnv allow`
      '';
    };
  };
}