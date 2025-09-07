if status is-interactive; and command -v gnome-keyring-daemon > /dev/null
    if not pgrep -f gnome-keyring-daemon > /dev/null 2>&1
        # Iniciar gnome-keyring y capturar todas las variables
        set -l keyring_output (gnome-keyring-daemon --start --components=secrets,ssh,pkcs11)
        
        # Exportar las variables necesarias
        for line in (string split \n $keyring_output)
            if string match -q "*=*" $line
                set -l var_parts (string split = $line)
                set -gx $var_parts[1] (string replace ';' '' $var_parts[2])
            end
        end
    else
        # Si ya está ejecutándose, configurar las variables manualmente
        set -gx GNOME_KEYRING_CONTROL /run/user/(id -u)/keyring
        set -gx GNOME_KEYRING_PID (pgrep -f gnome-keyring-daemon)
    end
end
