function[dispersion] = calculo_dispersion_pendiente(x, y)

    % esto est� pensado para descartar perfiles que en uno de sus lados no
    % tienen pocos puntos, pero lo que ven es ruido. Si es un perfil espero que
    % la pendiente est� bastante bien definida

    paso_x = diff(x);
    paso_y = diff(y);

    pendiente = paso_y./paso_x;

    dispersion = std(pendiente);

end