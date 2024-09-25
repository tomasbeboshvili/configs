#!/bin/bash
echo "Esto es un instalador de un tema en específico de KDE"
echo "Voy a instalar los temas de WhiteSur, créditos a Vinceliuice."
echo "Necesito tu contraseña para realizar cambios en el sistema."

# Verificar sistema operativo y usar el gestor de paquetes adecuado
# Esto mira en /etc/os-release, y intenta sacar el id de cada os
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
    BASED=$ID_LIKE # el importante, con esto puedes saber el sistema de paquetes que se usa
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VERSION=$DISTRIB_RELEASE
else
    OS=$(uname -s)
    VERSION=$(uname -r)
fi

# Mostrar información del sistema operativo
echo "Operating System: $OS"
echo "Version: $VERSION"
if [ -n "$BASED" ]; then
    echo "Based in: $BASED"
else
    echo "Based in: No information available"
fi

# Actualizar sistema según el gestor de paquetes
echo "Actualizando sistema..."
if [ "$OS" == "fedora" ]; then
    sudo dnf update -y
elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
    sudo apt update && sudo apt upgrade -y
elif [ "$OS" == "arch" ] || [ "$BASED" == "arch" ]; then
    sudo pacman -Syu --noconfirm
else
    echo "Gestor de paquetes desconocido. Por favor, actualiza manualmente."
fi

# Crear directorio de trabajo si no existe
if [ ! -d "miscellaneous" ]; then
    mkdir ~/miscellaneous
fi
cd ~/miscellaneous

# Verificar si git está instalado antes de continuar
if ! command -v git &> /dev/null; then
    echo "git no está instalado. Instalándolo..."
    if [ "$OS" == "fedora" ]; then
        sudo dnf install git -y
    elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
        sudo apt install git -y
    elif [ "$OS" == "arch" ] || [ "$BASED" == "arch" ]; then
        sudo pacman -S git --noconfirm
    else
        echo "No se puede instalar git automáticamente. Instálalo manualmente y vuelve a intentarlo."
        exit 1
    fi
fi

# Verificar si kitty está instalado antes de continuar
if ! command -v kitty &> /dev/null; then
    echo "kitty no está instalado. Instalándolo..."
    if [ "$OS" == "fedora" ]; then
        sudo dnf install kitty -y
    elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
        sudo apt install kitty -y
    elif [ "$OS" == "arch" ] || [ "$BASED" == "arch" ]; then
        sudo pacman -S kitty --noconfirm
    else
        echo "No se puede instalar kitty automáticamente. Instálalo manualmente y vuelve a intentarlo."
        exit 1
    fi
fi

# Verificar si cargo está instalado
if ! command -v cargo &> /dev/null; then
    echo "cargo no está instalado. Instalándolo..."
    if [ "$OS" == "fedora" ]; then
        sudo dnf install cargo -y
    elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
        sudo apt install cargo -y
    elif [ "$OS" == "arch" ] || [ "$BASED" == "arch" ]; then
        sudo pacman -S cargo --noconfirm
    else
        echo "No se puede instalar cargo automáticamente. Instálalo manualmente y vuelve a intentarlo."
        exit 1
    fi
fi


# Clonar repositorios de temas
cd ~/miscellaneous
echo "Clonand  e instalando temas de WhiteSur..."
git clone https://github.com/vinceliuice/WhiteSur-kde.git && ./WhiteSur-kde/install.sh
if [ $? -ne 0 ]; then
    echo "Error durante la instalación del tema general."
    exit 1
fi


git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git && ./WhiteSur-icon-theme/install.sh
if [ $? -ne 0 ]; then
    echo "Error durante la instalación de los iconos."
    exit 1
fi


git clone https://github.com/vinceliuice/WhiteSur-cursors.git && ./WhiteSur-cursors/install.sh
if [ $? -ne 0 ]; then
    echo "Error durante la instalación de cursores."
    exit 1
fi


git clone https://github.com/tomasbeboshvili/dotfiles.git

if ! cargo install --list | grep -q krabby; then
    cargo install krabby
else
    echo "krabby ya está instalado"
fi

cp -rf dotfiles/.config/* ~/.config/
cd dotfiles && stow --adopt .

# Selección de shell Bash o ZSH
echo "¿Quieres Descargar Oh My Bash o Oh My ZSH?"
echo "Elige una de estas opciones: [Bash (1), ZSH (2), nada (3)]"
opciones=("b" "z" "n")
select opt in "${opciones[@]}"; do
    case $opt in
        "b")
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" 
            break
            ;;
        "z")
            if ! command -v zsh &> /dev/null; then
                echo "zsh no está instalado, instalando..."
                if [ "$OS" == "fedora" ]; then
                    sudo dnf install zsh -y
                elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
                    sudo apt install zsh -y
                elif [ "$OS" == "arch" ] || [ "$BASED" == "arch" ]; then
                    sudo pacman -S zsh --noconfirm
                else
                    echo "No se puede instalar zsh automáticamente. Instálalo manualmente y vuelve a intentarlo."
                    exit 1
                fi
            fi
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
            cp -f dotfiles/.zshrc ~/
            break
            ;;
        "n")
            echo "No se instalará nada"
            break
            ;;
        *)
            echo "Opción no válida, por favor selecciona [1-3]"
            ;;
    esac
done



echo "¡La instalación se completó con éxito!"
echo "Temas de WhiteSur instalados y configuraciones aplicadas."

echo "Ahora queda que entres en la configuracion de aparencia y apliques los temas"
