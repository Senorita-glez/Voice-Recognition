function code = train(traindir, n)
% Speaker Recognition: Training Stage (with noise augmentation)

k = 16;  % número de centroides

% Cargar un archivo de ruido externo
noise_dir = 'carpeta/ruidos/';  % Ajusta al path donde tengas los archivos de ruido
s_noisy = addNoiseToSignal(s, noise_dir, 10);

for i = 1:n
    file = sprintf('%ss%d.wav', traindir, i);
    disp(['Processing ' file]);

    [s, fs] = audioread(file);   % usa audioread en lugar de wavread

    if fs ~= fs_noise
        noise = resample(noise, fs, fs_noise);  % ajustar frecuencia de muestreo si es necesario
    end

    % Señal limpia
    v_clean = mfcc(s, fs);

    % Señal contaminada con ruido a 10 dB SNR
    s_noisy = addNoiseToSignal(s, noise, 10);
    v_noisy = mfcc(s_noisy, fs);

    % Combinar ambos conjuntos de MFCCs
    v_combined = [v_clean, v_noisy];

    % Entrenar codebook con MFCCs combinados
    code{i} = vqCodeBook(v_combined, k);
end
