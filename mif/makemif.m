clc;clear;
fild = fopen('image.mif','wt');%����mif�ļ�
fhex = fopen('E:/_CM0_Soc/Cortex-M0/keil/USER/CM0.hex');
% tline=get_lines(fhex);
fclose(fhex);
fhex = fopen('E:/_CM0_Soc/Cortex-M0/keil/USER/CM0.hex');
%д��mif�ļ��ļ�ͷ
fprintf(fild, '%s\n','WIDTH=32;');%λ��
fprintf(fild, 'DEPTH=4096;\n');%λ��
fprintf(fild, '%s\n','ADDRESS_RADIX=HEX;');%��ַ��ʽ
fprintf(fild, '%s\n\n','DATA_RADIX=HEX;');%���ݸ�ʽ
fprintf(fild, '%s\t','CONTENT');%��ַ
fprintf(fild, '%s\n','BEGIN');%
for i = 1:3173 %tline
    % addr    :    data;
    fprintf(fild, '\t%x\t',(i - 1));%��ַ����0��ʼ����
    fprintf(fild, '%s\t',':');
    A = fscanf(fhex, '%x', 1);
    fprintf(fild, '%08x',A);
    fprintf(fild, '%s\n',';');
end
for i = 3173 + 1:4096
    fprintf(fild, '\t%x\t',(i - 1));%��ַ����0��ʼ����
    fprintf(fild, '%s\t',':');
    fprintf(fild, '%08x',0);
    fprintf(fild, '%s\n',';');
end
fprintf(fild, '\n%s','END');