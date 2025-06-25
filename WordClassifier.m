%% Clasificador RF + SVM con MFCC, delta y formantes
clear; clc;

personas = {'Andoni', 'Daphne', 'Edkir', 'Uriel'};
basePath = 'Audios';

X = [];
Y = {};
fprintf('Extrayendo características...\n');

for p = 1:length(personas)
    carpeta = fullfile(basePath, personas{p});
    files = dir(fullfile(carpeta, '*.wav'));

    for i = 1:length(files)
        try
            [audio, fs] = audioread(fullfile(carpeta, files(i).name));
            audio = bandpass(audio, [300 3400], fs);
            audio = audio / max(abs(audio));
            audio = audio(:);

            % MFCC básico (sin argumentos extra)
            mfccs = mfcc(audio, fs);
            mfccs = mfccs(:, 1:min(size(mfccs, 2), 20));  % limitar a 20

            % Delta y delta-delta manual
            delta = deltas(mfccs);
            deltaDelta = deltas(delta);
            mfccFull = [mfccs delta deltaDelta];

            if size(mfccFull,1) < 2, continue; end
            mfccMean = mean(mfccFull, 1);
            mfccStd  = std(mfccFull, 0, 1);

            % Formantes F1, F2, F3
            a = lpc(audio, 12);
            rts = roots(a);
            rts = rts(imag(rts) >= 0);
            angz = atan2(imag(rts), real(rts));
            formants = sort(angz * (fs / (2*pi)));
            formants = formants(formants > 90 & formants < 4000);
            formants = [formants(:); zeros(3,1)];
            F1 = formants(1); F2 = formants(2); F3 = formants(3);

            features = [mfccMean mfccStd F1 F2 F3];
            features(isnan(features)) = 0;
            X = [X; features];

            palabra = regexp(files(i).name, '^(Casa|Lluvia|Nube|Perro|Tren)', 'match', 'once');
            if isempty(palabra), continue; end
            Y{end+1} = palabra;

        catch ME
            warning('Error en %s: %s', files(i).name, ME.message);
        end
    end
end

Y = categorical(Y);
fprintf('\n📊 Distribución de palabras:\n');
tabulate(Y)

%% Grid Search - Random Forest
fprintf('\n🌲 Grid Search - Random Forest...\n');
nTreesList = [50, 100, 150];
mejorAccRF = 0;

X_norm = normalize(X);

for nTrees = nTreesList
    rf = TreeBagger(nTrees, X_norm, Y, 'OOBPrediction', 'on');
    pred = categorical(string(predict(rf, X_norm)));
    acc = mean(pred == Y);
    fprintf('nTrees = %d → %.2f%%\n', nTrees, acc*100);
    if acc > mejorAccRF
        mejorAccRF = acc;
        mejorRF = rf;
    end
end

fprintf('✅ Mejor RF: %.2f%%\n', mejorAccRF*100);

%% Grid Search - SVM
fprintf('\n📈 Grid Search - SVM...\n');
kernelTypes = {'linear', 'rbf'};
boxVals = [0.1, 1, 10];
mejorAccSVM = 0;

for i = 1:length(kernelTypes)
    for j = 1:length(boxVals)
        t = templateSVM('KernelFunction', kernelTypes{i}, 'BoxConstraint', boxVals(j));
        svm = fitcecoc(X, Y, 'Learners', t);
        pred = predict(svm, X);
        acc = mean(pred == Y);
        fprintf('Kernel = %-7s | Box = %.1f → %.2f%%\n', kernelTypes{i}, boxVals(j), acc*100);
        if acc > mejorAccSVM
            mejorAccSVM = acc;
            mejorSVM = svm;
        end
    end
end

fprintf('✅ Mejor SVM: %.2f%%\n', mejorAccSVM*100);

%% Guardar modelos
save('modeloRF_MFCC_Formantes.mat', 'mejorRF');
save('modeloSVM_MFCC_Formantes.mat', 'mejorSVM');

%% Función auxiliar para delta
function d = deltas(x)
    win = [-0.5 0 0.5];  % derivada central
    d = filter(win, 1, x, [], 1);
end
