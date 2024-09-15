{ fetchzip }:
let
  fetchvsix = args: fetchzip (args // { extension = "zip"; stripRoot = false; });
in
{
  theiaPlugins = {
    "vscode-builtin-cpp" = fetchvsix { url = "https://open-vsx.org/api/vscode/cpp/1.52.1/file/vscode.cpp-1.52.1.vsix"; hash = "sha256-QjptXQkXGaGo6z8cbW97xSWmAuPEC4fuMHhJBwh3sDU="; };
    "vscode-arduino-api" = fetchvsix { url = "https://github.com/dankeboy36/vscode-arduino-api/releases/download/0.1.2/vscode-arduino-api-0.1.2.vsix"; hash = "sha256-9Zd+aFX/HjiqU8vw7pibcZPL392eepTgW3ew/Q6pXJc="; };
    "vscode-arduino-tools" = fetchvsix { url = "https://downloads.arduino.cc/vscode-arduino-tools/vscode-arduino-tools-0.0.2-beta.8.vsix"; hash = "sha256-aKcq+lAfNwCGP4m3bkvjLEHblu7SYLEOnZkY8bjqRm8="; };
    "vscode-builtin-json" = fetchvsix { url = "https://open-vsx.org/api/vscode/json/1.46.1/file/vscode.json-1.46.1.vsix"; hash = "sha256-ocd7kW1bzV2vwT1ybXDyMBVRDAcOc6HlYyCv2y31a2Q="; };
    "vscode-builtin-json-language-features" = fetchvsix { url = "https://open-vsx.org/api/vscode/json-language-features/1.46.1/file/vscode.json-language-features-1.46.1.vsix"; hash = "sha256-QjYMiY1JuKA63CLWioY6a/aEOv+pLnNWS0bCr/Gp06w="; };
    "cortex-debug" = fetchvsix { url = "https://downloads.arduino.cc/marus25.cortex-debug/marus25.cortex-debug-1.5.1.vsix"; hash = "sha256-bboQEpu6piFHfJbM7Nj++aO4zSDQ9Fi/NFT+u5o7vww="; };
    "vscode-language-pack-bg" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-bg/1.48.3/file/MS-CEINTL.vscode-language-pack-bg-1.48.3.vsix"; hash = "sha256-TyBLaOcq/ZD03OELticnNQZ0c9cyROHetVzYb99Tl48="; };
    "vscode-language-pack-cs" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-cs/1.78.0/file/MS-CEINTL.vscode-language-pack-cs-1.78.0.vsix"; hash = "sha256-TOvu9zFWQ1F1RnOlrIAQnGT6ajDj7RlR19HAH736sz8="; };
    "vscode-language-pack-de" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-de/1.78.0/file/MS-CEINTL.vscode-language-pack-de-1.78.0.vsix"; hash = "sha256-yOHCHfO+Ce0KYTwOk7Xg67EBYZm/XDFxS5HC960VLiY="; };
    "vscode-language-pack-es" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-es/1.78.0/file/MS-CEINTL.vscode-language-pack-es-1.78.0.vsix"; hash = "sha256-1vRmsjIBeatAIdE5vM+jBC3YAq3gEjaiSOWkaBrphCo="; };
    "vscode-language-pack-fr" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-fr/1.78.0/file/MS-CEINTL.vscode-language-pack-fr-1.78.0.vsix"; hash = "sha256-09waylPuGnKYp3e4yC1cPorWBGZbEaLvVShDW1joVd4="; };
    "vscode-language-pack-hu" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-hu/1.48.3/file/MS-CEINTL.vscode-language-pack-hu-1.48.3.vsix"; hash = "sha256-DRv3CnKoFF72kBTjoOhhKCP7pzLEv9QfZRflIs906zk="; };
    "vscode-language-pack-it" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-it/1.78.0/file/MS-CEINTL.vscode-language-pack-it-1.78.0.vsix"; hash = "sha256-T+JjlBDeMNEQgoa/6H/LAbuj9z6htX1FTGAuO63CUqQ="; };
    "vscode-language-pack-ja" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-ja/1.78.0/file/MS-CEINTL.vscode-language-pack-ja-1.78.0.vsix"; hash = "sha256-Gyc0dwbK/rwnIuU7QZz5tH+aFirXJLZir3WUAtKeL7Y="; };
    "vscode-language-pack-ko" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-ko/1.78.0/file/MS-CEINTL.vscode-language-pack-ko-1.78.0.vsix"; hash = "sha256-CDo4keTn7iFoBeSwps4+dLmrd2jmNopxyqwgnoZ2adM="; };
    "vscode-language-pack-nl" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-nl/1.48.3/file/MS-CEINTL.vscode-language-pack-nl-1.48.3.vsix"; hash = "sha256-t26UZwEEACAb1+XyN2TcC1GKqU3PoD71BBkuN+0Y0+s="; };
    "vscode-language-pack-pl" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-pl/1.78.0/file/MS-CEINTL.vscode-language-pack-pl-1.78.0.vsix"; hash = "sha256-UROiOMwuWDqDcHMXP0kam35+7No+4NVIKKUcamZY4fE="; };
    "vscode-language-pack-pt-BR" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-pt-BR/1.78.0/file/MS-CEINTL.vscode-language-pack-pt-BR-1.78.0.vsix"; hash = "sha256-a1zgihh0Dqc32TLFf1rscfQtgmRHJYIsCbzrstBEpeg="; };
    "vscode-language-pack-ru" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-ru/1.78.0/file/MS-CEINTL.vscode-language-pack-ru-1.78.0.vsix"; hash = "sha256-wIHOnXbvqvKvhlX8wbW2A+K75XEl0mNqENkNvZTuF2M="; };
    "vscode-language-pack-tr" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-tr/1.78.0/file/MS-CEINTL.vscode-language-pack-tr-1.78.0.vsix"; hash = "sha256-9HlFa20DLotjKRnC20+/L77qQ8L9o1pUayZeSCyKaYo="; };
    "vscode-language-pack-uk" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-uk/1.48.3/file/MS-CEINTL.vscode-language-pack-uk-1.48.3.vsix"; hash = "sha256-GJ+s1EVxTCuCuJ5h+YfWWk48FFp9+LllmQoguWWmxJ0="; };
    "vscode-language-pack-zh-hans" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-zh-hans/1.78.0/file/MS-CEINTL.vscode-language-pack-zh-hans-1.78.0.vsix"; hash = "sha256-L/sd/KHNFIInJZBZHScDLV107iNpRNddwDN8q5WHt6g="; };
    "vscode-language-pack-zh-hant" = fetchvsix { url = "https://open-vsx.org/api/MS-CEINTL/vscode-language-pack-zh-hant/1.78.0/file/MS-CEINTL.vscode-language-pack-zh-hant-1.78.0.vsix"; hash = "sha256-uXsBY6I3vXJLrQPa8uMrSInsh5JO0ZEJVlCnrofK7mM="; };
  };
}
