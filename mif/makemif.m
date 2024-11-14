clc;clear;
fild = fopen('image.mif','wt');%创建mif文件
fhex = fopen('E:/_CM0_Soc/Cortex-M0/keil/USER/CM0.hex');
% tline=get_lines(fhex);
fclose(fhex);
fhex = fopen('E:/_CM0_Soc/Cortex-M0/keil/USER/CM0.hex');
%写入mif文件文件头
fprintf(fild, '%s\n','WIDTH=32;');%位宽
fprintf(fild, 'DEPTH=4096;\n');%位宽
fprintf(fild, '%s\n','ADDRESS_RADIX=HEX;');%地址格式
fprintf(fild, '%s\n\n','DATA_RADIX=HEX;');%数据格式
fprintf(fild, '%s\t','CONTENT');%地址
fprintf(fild, '%s\n','BEGIN');%
for i = 1:3173 %tline
    % addr    :    data;
    fprintf(fild, '\t%x\t',(i - 1));%地址，从0开始编码
    fprintf(fild, '%s\t',':');
    A = fscanf(fhex, '%x', 1);
    fprintf(fild, '%08x',A);
    fprintf(fild, '%s\n',';');
end
for i = 3173 + 1:4096
    fprintf(fild, '\t%x\t',(i - 1));%地址，从0开始编码
    fprintf(fild, '%s\t',':');
    fprintf(fild, '%08x',0);
    fprintf(fild, '%s\n',';');
end
fprintf(fild, '\n%s','END');