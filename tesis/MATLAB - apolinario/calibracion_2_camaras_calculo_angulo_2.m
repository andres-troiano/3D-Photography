% m�s f�cil: me hice una funci�n que procesa toda la lut y te devuelve el
% array de �ngulos

clear variables

camara = '2';

path = 'C:\Users\60069978\Documents\MATLAB\medicion18\';

% cargo el txt que tiene las coords medidas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lut = [path 'camara_' camara '\LUT_camara_' camara '.txt'];
lut = [path 'camara_' camara '\LUT_curada_camara_' camara '.txt'];
output_file = [path 'camara_' camara '\angulos_camara_' camara '.txt'];

calculo_angulo_perfil(lut, path, output_file);