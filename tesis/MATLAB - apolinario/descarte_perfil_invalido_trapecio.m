function[fig_name, flag_descarte] = descarte_perfil_invalido_trapecio(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y, dispersion_1, dispersion_2, x, y)
    
%     param_rectas son los par�metros de las 2 rectas, en este orden:
%     a1, b1, a2, b2

    a1 = param_rectas(1);
    b1 = param_rectas(2);
    a2 = param_rectas(3);
    b2 = param_rectas(4);

    flag_descarte = 0;
    fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    
    % pido que ambas regiones tengan al menos 20 puntos
    if numel(datos_y_1) < 21 || numel(datos_y_2) < 21
        fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
        flag_descarte = -1;
    end
    
    if numel(datos_y_1) > 0 & numel(datos_y_2) > 0
        
        extremo_izq_y = datos_y_1(1);
        extremo_der_y = datos_y_2(end);

        [punta_px, punta_py] = calculo_punta_dados_parametros(a1, b1, a2, b2);

        % tiro perfiles donde casi no se ve el flanco izquierdo
        % delta_x_1 es el rango en px_x que cubre el flanco izquierdo
        delta_x_1 = datos_x_1(end) - datos_x_1(1);
        if delta_x_1 <= 5
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 2;
        end

        % idem lado derecho
        delta_x_2 = datos_x_2(end) - datos_x_2(1);
        if delta_x_2 <= 5
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 3;
        end

        % cambio esta condici�n por: punta por debajo de un pixel l�mite que
        % considero demasiado bajo
        if punta_py < 5
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 5;
        end

        % si una regi�n sali� con muy pocos puntos (porque no se alcanz� a
        % ver), tiro el frame. Corto en 10 puntos. Ac� lo hago s�lo para la
        % regi�n izquierda, que es donde lo observ�
        if numel(datos_x_1) < 15
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 6;
        end

        % idem lado derecho
        % ojo: esto lo agregu� por la c�mara 2. No deber�a romper nada en la 1,
        % pero vale tenerlo en cuenta
        if numel(datos_x_2) < 15
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 7;
        end

        % tiro perfiles con muy pocos puntos, que esperar�a que no sean puntas.
        % O si lo son, que est�n bastante mal medidas
        if numel(datos_x_1) + numel(datos_x_2) < 55
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 8;
        end

        

        if camara == '1'

            % con esto quiero descartar un caso muy raro en el que la punta queda
            % m�s arriba que muchos puntos de la regi�n 1.
            % Esto siempre pasa en la c�mara 2. Quiz�s sirva para la 1

            % ojo que no me tire perfiles buenos
            if punta_py > median(datos_y_1) - std(datos_y_1)
                fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
                flag_descarte = 9;
            end

            % si agarr� la punta equivocada, y la punta correcta no la veo
            if a2 > 0
                fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
                flag_descarte = 10;
            end

            % siempre la pendiente 1 tiene que ser bastante mayor en m�dulo a la
            % pendiente 2
            if a1/a2 < 2
                fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
                flag_descarte = 11;
            end

        end
        
        if camara == '2'
            % si agarr� la punta equivocada, y la punta correcta no la veo
            if a1 > 0
                fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
                flag_descarte = 10;
            end

            % cuando veo b�sicamente una l�nea horizontal
            if max([abs(a1), abs(a2)]) < 0.2
                fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
                flag_descarte = 11;
            end

        end

        % si la punta qued� dentro de una de las 2 regiones
        if punta_px > datos_x_2(1) + 7 || punta_px < datos_x_1(end) - 7
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 12;
        end

        % si uno de los lados es ruido pero no tiene pocos puntos
        if dispersion_1 > 0.95 || dispersion_2 > 0.95
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 13;
        end        

        % si me qued� el perfil cortado groseramente. Usando el trapecio no
        % deber�a tener huecos que no proviniesen de esta situaci�n
        % Para evitar el problema de que despu�s de la recuperaci�n de datos
        % v�lidos aparecen huecos, uso los datos originales solamente habi�ndoles
        % sacado los ceros. Ah� ya se ve si el perfil est� cortado
        paso_x = diff(x);
        filtro = paso_x > 60;
        % por qu� andaba esto?
        % filtro = [true filtro];
        paso_grande = paso_x(filtro);

        if numel(paso_grande) > 1
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 14;
        end  

        % si las pendientes son muy parecidas
        if min([abs(a1), abs(a2)])/max([abs(a1), abs(a2)]) > 0.5
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 15;
        end  

    end
    
end