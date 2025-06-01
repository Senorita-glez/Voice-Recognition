function s_noisy = addNoise(s, noise_dir, snr_db)
    % Añade ruido desde un archivo aleatorio en la carpeta noise_dir

    % 1. Obtener lista de archivos de ruido
    noise_files = dir(fullfile(noise_dir, '*.wav'));
    if isempty(noise_files)
        error('No se encontraron archivos .wav en la carpeta %s', noise_dir);
    end

    % 2. Seleccionar uno aleatoriamente
    idx = randi(length(noise_files));
    noise_file = fullfile(noise_dir, noise_files(idx).name);

    % 3. Leer el archivo de ruido
    [noise, fs_noise] = audioread(noise_file);
    noise = mean(noise, 2);  % convertir a mono si es estéreo

    % 4. Igualar frecuencia de muestreo (asumimos fs=16k como estándar)
    fs_target = 16000;  % O cambia a la frecuencia real de tu señal s
    if exist('s', 'var') && ~isempty(s)
        fs_target = round(1 / mean(diff((1:length(s)) / fs_target))); % infiere si se conoce
    end
    if fs_noise ~= fs_target
        noise = resample(noise, fs_target, fs_noise);
    end

    % 5. Igualar duración del ruido
    if length(noise) < length(s)
        noise = repmat(noise, ceil(length(s)/length(noise)), 1);
    end
    noise = noise(1:length(s));

    % 6. Escalar el ruido al SNR deseado
    signal_power = mean(s.^2);
    noise_power = mean(noise.^2);
    scaling_factor = sqrt(signal_power / (10^(snr_db/10) * noise_power));
    noise_scaled = noise * scaling_factor;

    % 7. Señal contaminada
    s_noisy = s + noise_scaled;
end
