% This code was written by Kriztina Kelevitz and Brie Corsa
% To reference, please refer to:

% 1. Kelevitz, K., Tiampo, K., Corsa, B. Improved Real-Time Natural Hazard Monitoring Automated DInSAR Time Series.
% Remote Sensing 2021, 13(5), 867. https://doi.org/10.3390/rs13050867
% 2. Corsa, B., Barba-Sevilla, M., Tiampo, K., Meertens, C. Integration of DInSAR time series and GNSS Data for continuous volcanic 
% deformation monitoring and eruption early warning applications. Remote Sens. 2022, 14, 784. https://doi.org/10.3390/rs14030784


function status=make_correction(dir,fln_phase,fln_ztd1,fln_ztd2,fln_elev,elev,unit_phase,wavelength,unit_out,isplanar,iswrap,ref_lat,ref_lon,void_value)

dir=[dir,'/'];

[wid,len,xfirst,yfirst,xstep,ystep]=read_header([dir,fln_phase,'.rsc']);

%read phase and convert to meters
grdfile=strcat(dir,fln_phase);

fid=fopen([dir,fln_phase],'rb');
[xvec,yvec,phase]=grdread2(grdfile);
if(strcmp(unit_phase,'p')==1)
  phase=phase*wavelength/(4*pi);
end
if(strcmp(unit_phase,'c')==1)
  phase=phase/100.0;
end
fclose(fid);


% for i=1:wid
%     for j=1:len
%         cx(i,j)=xvec(i);
%         cy(i,j)=yvec(j);
%     end
% end


%define axis for plotting
% cx=zeros(wid,len); 
% cy=zeros(wid,len); 
% for i=1:wid
%     for j=1:len
%         cx(i,j)=xfirst+(i-1)*xstep;
%         cy(i,j)=yfirst+(j-1)*ystep;
%     end
% end

cx=xvec;
cy=yvec;

%cut image to be exactly the same with interferogram
cut_image2(dir,fln_ztd1,yfirst,len,xfirst,wid,'ztd1');
cut_image2(dir,fln_ztd2,yfirst,len,xfirst,wid,'ztd2');
if(exist([dir,fln_elev],'file'))
   cut_image2(dir,fln_elev,yfirst,len,xfirst,wid,'elev');
end




%read ztd files from GACOS
fid=fopen([dir,'ztd1'],'rb');
ztd1=fread(fid,[wid, len],'float');
fclose(fid);
delete([dir,'ztd1']);
delete([dir,'ztd1.rsc']);

fid=fopen([dir,'ztd2'],'rb');
ztd2=fread(fid,[wid, len],'float');
fclose(fid);
delete([dir,'ztd2']);
delete([dir,'ztd2.rsc']);

%difference ztd
dztd=ztd2-ztd1;
clear ztd1 ztd2

% fid=fopen([dir,'SAR_ZTD_Map.phs.cut'],'rb');
% dztd=fread(fid,[wid,len],'float');
% fclose(fid);

index=find(phase==0 | isnan(phase));

%set reference point
phase(index)=nan;
if(ref_lon==0 && ref_lat==0)
    meanp=mean(phase(:),'omitnan');
    [value,ref_index]=min(abs(phase(:)-meanp));
    
    
    [row,col]=ind2sub(size(phase), ref_index);
    
else
    row=round((yfirst-ref_lat)/(-ystep));
    col=round((ref_lon-xfirst)/xstep);  
    
end


%phase=phase';
%phase=fliplr(phase);

dztd=dztd';

phase=phase-phase(row,col);
dztd=dztd-dztd(row,col);


%set to output unit
if(strcmp(unit_out,'p')==1)
  phase=phase/(wavelength/(4*pi));
  dztd=dztd/(wavelength/(4*pi));
end
if(strcmp(unit_out,'c')==1)
  phase=phase*100.0;
  dztd=dztd*100.0;
end

%read elev file
if(exist([dir,fln_elev],'file'))
    fid=fopen([dir,'elev'],'rb');
    elevdata=fread(fid,[wid, len],'float');
    fclose(fid);
    dztd=dztd./sin(elevdata);
else
    elev=elev*3.14159265/180.0;
    dztd=dztd./sin(elev);   
end

%correction
corrected=phase+dztd;
corrected(index)=void_value;
dztd(index)=void_value;
fid=fopen([dir,'dztd'],'wb');
fwrite(fid,dztd,'float');
fclose(fid);

fid=fopen([dir,'phase'],'wb');
fwrite(fid,phase,'float');
fclose(fid);
copyfile([dir,fln_phase,'.rsc'],[dir,'phase.rsc']);

fid=fopen([dir,'phase-ztd'],'wb');
fwrite(fid,corrected,'float');
fclose(fid);
copyfile([dir,fln_phase,'.rsc'],[dir,'phase-ztd.rsc']);

if(isplanar~=0)
    detrend=remove_planar(corrected);
    fid=fopen([dir,'phase-ztd-pnanar'],'wb');
    fwrite(fid,detrend,'float');
    fclose(fid);
    copyfile([dir,fln_phase,'.rsc'],[dir,'phase-ztd-planar.rsc']);
end

phase(index)=nan;
dztd(index)=nan;
corrected(index)=nan;


%%wrapdata

if(iswrap>0)
    phase_w=wrap_matrix(phase,-iswrap,iswrap);
    dztd_w=wrap_matrix(dztd,-iswrap,iswrap);
    corrected_w=wrap_matrix(corrected,-iswrap,iswrap);
end


if(isplanar~=0)
    fnum=4;
end 
fnum=2;
%plot
phase(index)=nan;
caxmin=mean(phase(:),'omitnan')-2*std(phase(:),'omitnan');
caxmax=mean(phase(:),'omitnan')+2*std(phase(:),'omitnan');
% caxmin=-5;
% caxmax=5;

clear co
clear index1
if(iswrap>0)
    caxmin=-iswrap;
    caxmax=iswrap;
end
f1=figure('Name','GACOS Atmopsheric Correction Results','NumberTitle','off','Color','white');
set(f1,'DefaultFigureVisible', 'on')
ax1 = subplot(fnum,2,1);
phase(index)=nan;
colormap(ax1,jet(wid));
if(iswrap>0)
   hidp = pcolor(cx,cy,phase_w);
else
   hidp = pcolor(cx,cy,phase);
end
caxis([caxmin,caxmax])
cb=colorbar;
if(strcmp(unit_out,'c')==1)
   title(cb,'cm')
end
if(strcmp(unit_out,'m')==1)
   title(cb,'m')
end
if(strcmp(unit_out,'p')==1)
   title(cb,'rad')
end
set(hidp,'LineStyle','none');
axis equal
set(gca,'YDir','normal');
set(gca,'TickDir','out');
set(gca,'XLim',[min(cx(:)),max(cx(:))]);
set(gca,'YLim',[min(cy(:)),max(cy(:))]); 
title('Phase');

clear phase


ax2 = subplot(fnum,2,2);
colormap(ax2,jet(wid));
if(iswrap>0)
   hidp = pcolor(cx,cy,dztd_w);
else
   hidp = pcolor(cx,cy,dztd);
end
caxis([caxmin,caxmax])
colorbar
set(hidp,'LineStyle','none');
axis equal
set(gca,'YDir','normal');
set(gca,'TickDir','out');
set(gca,'XLim',[min(cx(:)),max(cx(:))]);
set(gca,'YLim',[min(cy(:)),max(cy(:))]); 
title('Delay Corrections');
clear dztd

ax3 = subplot(fnum,2,3);
colormap(ax3,jet(wid));
if(iswrap>0)
   hidp = pcolor(cx,cy,corrected_w);
else
   hidp = pcolor(cx,cy,corrected);
end
caxis([caxmin,caxmax])
colorbar
set(hidp,'LineStyle','none');
axis equal
set(gca,'YDir','normal');
set(gca,'TickDir','out');
set(gca,'XLim',[min(cx(:)),max(cx(:))]);
set(gca,'YLim',[min(cy(:)),max(cy(:))]); 
title('Phase - Delay Corrections');

%corrected=fliplr(corrected);

%corrected=corrected';

grdwrite2(xvec,yvec,corrected,strcat(grdfile,'.atm'))

clear corrected

if(isplanar==1)   
    detrend=detrend-detrend(col,row);
    detrend(index)=nan;
    if(iswrap>0)
        detrend_w=wrap_matrix(detrend,-iswrap,iswrap);
    end
    ax4 = subplot(fnum,2,4);
    colormap(ax4,jet(wid));
    if(iswrap>0)
        hidp = pcolor(cx,cy,detrend_w);
    else
        hidp = pcolor(cx,cy,detrend);
    end
    caxis([caxmin,caxmax])
    colorbar
    set(hidp,'LineStyle','none');
    axis equal
    set(gca,'YDir','normal');
    set(gca,'TickDir','out');
    set(gca,'XLim',[min(cx(:)),max(cx(:))]);
    set(gca,'YLim',[min(cy(:)),max(cy(:))]);
    title('Phase - Delay Corrections - Planar');
end

saveas(f1,[dir,fln_phase,'.fig.jpg']);

status=1;

