function[fig_name, flag_descarte] = descarte_perfil_invalido(param_rectas, datos_x_1, datos_y_1, datos_x_2, datos_y_2, camara, tag_x, tag_y)
    
%     param_rectas son los par�metros de las 2 rectas, en este orden:
%     a1, b1, a2, b2

    a1 = param_rectas(1);
    b1 = param_rectas(2);
    a2 = param_rectas(3);
    b2 = param_rectas(4);

    flag_descarte = 0;
    fig_name = ['plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    
    if numel(datos_y_1) == 0 || numel(datos_y_2) == 0
        fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
        flag_descarte = -1;
    end
    
    if numel(datos_y_1) > 0 && numel(datos_y_2) > 0
        
        extremo_izq_y = datos_y_1(1);
        extremo_der_y = datos_y_2(end);

        punta_py = a1*(b2 - b1)/(a1 - a2) + b1;

        % tiro aquellos perfiles donde la "punta" no es la que yo deseo
        if punta_py > extremo_izq_y || punta_py > extremo_der_y
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 1;
        end

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

        % tiro perfiles donde las 2 pendientes tienen el mismo signo
        if a1*a2 > 0 % (tienen igual signo)
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 4;
        end

    %     % tiro perfiles donde la punta sali� cortada porque se sali� del campo
    %     % visual de la c�mara. Pongo 5 px como tama�o l�mite del hueco
    %     
    %     hueco = datos_x_2(1) - datos_x_1(end);
    %     if hueco > 5
    %         fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
    %         flag_descarte = 5;
    %     end

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

        % con esto quiero descartar un caso muy raro en el que la punta queda
        % m�s arriba que muchos puntos de la regi�n 1

        % ojo que no me tire perfiles buenos
        if punta_py > median(datos_y_1) - std(datos_y_1)
            fig_name = ['descarte\plot_camara_' camara '_x_' tag_x '_y_' tag_y];
            flag_descarte = 9;
        end
        
    end
    
end