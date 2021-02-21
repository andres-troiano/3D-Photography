function[punta_px, punta_py, datos_x_1, datos_y_1, recta_1, datos_x_2, datos_y_2, recta_2, flag_descarte] = hexagono_individual_funcion(directorio, camara, tag_x, tag_y, graficos, guardar)

    % funciona con el algoritmo que llam� "idea 2"

    % graficos vale 'on', 'off'
    % guardar vale 1 o 0

    dir_camara = ['camara_' camara '\'];

    set(0,'DefaultFigureVisible', graficos);

    filename = [directorio dir_camara 'LUT_camara_' camara '_frame_x_' tag_x '_y_' tag_y '.png'];

    frame = imread(filename);

    y_original = median(frame);
    y_original = double(y_original)/2^4;

    x_original = 1:1:numel(y_original);

    [x, y] = tiro_datos_nulos_perfil(x_original, y_original);

    % redefin� este proceso llamando a las variables x,y para que al
    % recuperar datos nunca me vuelva a agarrar la base
    
%     for j = 1:3
%         [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(y, x, -1, 3);
%         [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, 1, 3);
% 
%         [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, -1, 3);
%         [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, 1, 3);    
%         
%         datos_x = datos_x(2:end-1);
%         datos_y = datos_y(2:end-1);
%     end

    for j = 1
        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(y, x, -1, 2);
        [datos_y, datos_x, mediana, sigma] = filtro_valores_inusuales(datos_y, datos_x, 1, 2);

        [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, -1, 2);
        [datos_x, datos_y, mediana, sigma] = filtro_valores_inusuales(datos_x, datos_y, 1, 2);    
        
%         datos_x = datos_x(2:end-1);
%         datos_y = datos_y(2:end-1);
    end
    
    
% ten�a 2
    for j = 1:2

        [datos_x_1, datos_x_2, datos_y_1, datos_y_2, recta_1, recta_2, a1, b1, a2, b2, delta_1, delta_2] = receta_hexagono_idea_2(datos_x, datos_y, camara);
        [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

        if numel(datos_y_1) == 0
            continue
        end
        
        % ac� chequeo si tengo que redefinir los dominios y volver a correr
        % OJO! la 2da vez este resultado no lo estoy usando
        [datos_x, datos_y] = redefino_dominio_hexagono(x, y, datos_x, datos_y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, punta_px, punta_py, a1, a2, camara);
   
        
        [datos_x, datos_y] = filtro_basura_izquierda_absoluto(datos_x, datos_y);
    end
    
    close all
    figure
    hold on
    grid on
    
    plot(x, y, '.-b')
    plot(datos_x, datos_y, '.r')
    plot(datos_x_1, datos_y_1, '.g')
    plot(datos_x_2, datos_y_2, '.y')
    
    [datos_x_1, datos_y_1, datos_x_2, datos_y_2, a1, b1, a2, b2] = recupero_datos_validos_calculo_punta(x, y, datos_x_1, datos_y_1, datos_x_2, datos_y_2, recta_1, recta_2, delta_1, delta_2, punta_px, punta_py, a1, a2, b1, b2);
    [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

    %%%%%%%%%%%%%%%%%%%%%%% gr�fico %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    param_rectas = [a1, b1, a2, b2];

    dispersion_1 = calculo_dispersion_pendiente(datos_x_1, datos_y_1);
    dispersion_2 = calculo_dispersion_pendiente(datos_x_2, datos_y_2);

%     dispersion_1
%     dispersion_2

    [fig_name, flag_descarte] = descarte_perfil_invalido(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y);

    flag_descarte

% a1
% a2

% a2/a1
%     numel(datos_x_1)
%     numel(datos_x_2)
% min([a1, a2])/max([a1, a2])
% min([abs(a1), abs(a2)])/max([abs(a1), abs(a2)])


    % % numel(datos_x_1) + numel(datos_x_2)
%     numel(datos_x_1)
    % numel(datos_x_2)

    close all
    h = figure(1);
    hold on
    grid on

    plot(x_original, y_original, '.-c')
    plot(x, y, '.k')
    plot(datos_x, datos_y, '.b')
    plot(datos_x_1, datos_y_1, '.g')
    plot(datos_x_2, datos_y_2, '.y')
    plot(punta_px, punta_py, '*r')

    xlabel('pixel x')
    ylabel('pixel y')

    margen = 100;

    datos_x = [datos_x_1, datos_x_2];
    datos_y = [datos_y_1, datos_y_2];

    if numel(datos_x) > 0
        xlim([min(datos_x)-margen max(datos_x)+margen])
        ylim([min(datos_y)-margen max(datos_y)+margen])
    end

%     xlim([min(x) max(x)])
%     ylim([min(y) max(y)])

    % xlim([min([datos_x_1, datos_x_2])-margen max([datos_x_1, datos_x_2])+margen])
    % ylim([min([datos_y_1, datos_y_2])-margen max([datos_y_1, datos_y_2])+margen])

    if guardar == 1
        saveas(h, [directorio dir_camara fig_name], 'png');
    end

end