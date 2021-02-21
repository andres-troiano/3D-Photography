function[x, y] = coords_punta(separador, filename, plot_flag)
    
    frame = imread(filename);

    perfil = median(frame);
    perfil = double(perfil)/2^4;

    datos_x = [];
    datos_y = [];

    for i = 1:numel(perfil)
        if perfil(i) ~= 0
            datos_x = [datos_x i];
            datos_y = [datos_y perfil(i)];
        end
    end

    datos_x_temp = [];
    datos_y_temp = [];

    % tiro unos pocos puntos al final, que pertenecen al flanco que va del
    % trapecio a la mesa
    % Podr�a verlos al ppio tambi�n
    datos_x = datos_x(1:end-3);
    datos_y = datos_y(1:end-3);

    datos_x = datos_x(3:end);
    datos_y = datos_y(3:end);
    
    % antes de separar en regiones, trato de tirar el ruido del reflejo
    % miro la mediana a ver si est� sobre la punta, as� tiro los que est�n
    % muy por debajo
    mediana_y = median(datos_y);
    std_y = std(datos_y);
    
    datos_x_temp = [];
    datos_y_temp = [];
    
    for i = 1:numel(datos_x)
        if datos_y(i) > mediana_y - 2*std_y
            datos_x_temp = [datos_x_temp datos_x(i)];
            datos_y_temp = [datos_y_temp datos_y(i)];
        end
    end
    
    datos_x = datos_x_temp;
    datos_y = datos_y_temp;

    % me armo 2 regiones de datos para ajustar
    datos_x_1 = [];
    datos_y_1 = [];
    
    datos_x_2 = [];
    datos_y_2 = [];
    
    for i = 1:numel(datos_x)
        
        if datos_x(i) < separador
            datos_x_1 = [datos_x_1 datos_x(i)];
            datos_y_1 = [datos_y_1 datos_y(i)];
        end
        
        if datos_x(i) >= separador
            datos_x_2 = [datos_x_2 datos_x(i)];
            datos_y_2 = [datos_y_2 datos_y(i)];
        end
        
    end
    
    % parte opcional, falta el plot
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if plot_flag ~= 1
        plot_flag = 0;
    end
    
    if plot_flag == 1
    
        for j = 1:3

            [pol_1, S_1] = polyfit(datos_x_1, datos_y_1, 1);
            [pol_2, S_2] = polyfit(datos_x_2, datos_y_2, 1);

            [recta_1, delta_1] = polyval(pol_1, datos_x_1, S_1);
            [recta_2, delta_2] = polyval(pol_2, datos_x_2, S_2);

            % hay problemas cuando hay ruido distinto de 0. Filtro apartamientos
            % del ajuste

            sigmas = 3;

            % en la region 1:
            datos_x_1_filtrado = [];
            datos_y_1_filtrado = [];

            for i = 1:numel(datos_x_1)
                if (datos_y_1(i) > recta_1(i) - sigmas*delta_1(i)) && (datos_y_1(i) < recta_1(i) + sigmas*delta_1(i))
                    datos_x_1_filtrado = [datos_x_1_filtrado datos_x_1(i)];
                    datos_y_1_filtrado = [datos_y_1_filtrado datos_y_1(i)];
                end
            end

            datos_x_1 = datos_x_1_filtrado;
            datos_y_1 = datos_y_1_filtrado;

            % en la region 2:
            datos_x_2_filtrado = [];
            datos_y_2_filtrado = [];

            for i = 1:numel(datos_x_2)
                if (datos_y_2(i) > recta_2(i) - sigmas*delta_2(i)) && (datos_y_2(i) < recta_2(i) + sigmas*delta_2(i))
                    datos_x_2_filtrado = [datos_x_2_filtrado datos_x_2(i)];
                    datos_y_2_filtrado = [datos_y_2_filtrado datos_y_2(i)];
                end
            end

            datos_x_2 = datos_x_2_filtrado;
            datos_y_2 = datos_y_2_filtrado;

        end
        
        % calculo la punta
        %%%%%%%%%%%%%%%%%%
        
        a1 = pol_1(1);
        b1 = pol_1(2);

        a2 = pol_2(1);
        b2 = pol_2(2);
    
        % coordenadas de la punta
        x = (b2 - b1)/(a1 - a2);
        y = a1*(b2 - b1)/(a1 - a2) + b1;
        
        % plot
        %%%%%%
        
        tag = strsplit(filename, '.');
        tag = tag{1};
        %tag = strsplit(tag, 'LUT_frame_');
        tag = strsplit(tag, 'frame_calibracion_stages_');
        tag = tag{2};
        tag = strsplit(tag, '_');
        
        set(0,'DefaultFigureVisible', 'off');
    
        close all
        h = figure(1);
        hold on
        plot(datos_x, datos_y, '.b')
        plot([separador separador], [min(perfil) max(perfil)], '--k')
        plot(datos_x_1, datos_y_1, '.r')
        plot(datos_x_2, datos_y_2, '.g')
        plot(x, y, '*k')

        p = strsplit(filename, '\');
        path = [p{1}, '\', p{2}, '\', p{3}, '\', p{4}, '\', p{5}, '\', p{6}, '\'];

        fig_name = ['plot_x_' tag{2} '_y_' tag{4}];
        saveas(h, [path fig_name], 'png');
        
    end
    
end