function [hit]=ReadZedoSignal(folder,file)
            %folder='D:\Data\Vysoké učení technické v Brně\Fyzika.NDT - Dokumenty\Projekty\AE_Zedo\DataSource\A1\';
            %file='a-1.65.1a-ae-signal-hitdet0-id00156.txt';

            fileID=fopen([folder '\' file]);
            strBlock = textscan(fileID,'%s'); % Read the file as one block
            fclose(fileID);
            strBlock2=join(string(strBlock{1,1}));
            strArr=split(strBlock2,'#');

            term={' Number-of-samples: ',' PSD-Dominant-Frequency [Hz]: ',...
                ' Sampling-Rate[MHz]: ',' Raw-Sample-File: ',' Channel: ',...
                ' Hit-ID: ',' Time-Start-Relative[sec]: '};
            hit=struct();
            hit.SignalExist=false;
            hit.Description=strArr;
            %Cas hitu
            Index = find(contains(strArr,term{7}));
            hit.RelativeTime=double(strrep(strArr(Index),term{7},''));

            %Nazev karty
            Index = find(contains(strArr,term{5}));
            hit.Card=char(strrep(strArr(Index),term{5},''));

            %ID Hitu
            %Nazev karty
            parts=split(file,'-');
            id=str2double(replace(parts(end),'.txt',''));
            hit.ID=id;

            %Pocet vzorků
            Index = find(contains(strArr,term{1}));
            hit.nSamples=double(strrep(strArr(Index),term{1},''));

            %Dominantní frekvence
            Index = find(contains(strArr,term{2}));
            hit.PSDDominantFreq=double(strrep(strArr(Index),term{2},''));

            %Vzorkovací frekvence
            Index = find(contains(strArr,term{3}));
            tmp=double(strrep(strArr(Index),term{3},''));
            hit.SampleFreq=tmp(1)*1e+6;

            %Název souboru Bin
            Index = find(contains(strArr,term{4}));
            hit.BinFile=char(strrep(strArr(Index),term{4},''));

            %Nacteni datove řady
            binfilename=[folder '\' hit.BinFile];
            if exist(binfilename)
                fileIDBin=fopen(binfilename);
                hit.Signal = fread(fileID,hit.nSamples,'int16');
                hit.SignalExist=true;
                fclose(fileIDBin);
            end
        
        end