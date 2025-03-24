clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% user inputs
api_key=''; % enter API key
station_ID='lali';
sensor='one-sensor';
days_per_page=360; % maximum number of days spanning a page, max 3650days
start_date='2023-01-01'; % from date, included in result. Default is 8days in the past, 'YYYY-MM-DD'
end_date='2023-01-30'; % until date, not included in result. Default is day of request 'YYYY-MM-DD'
includesensors='prs';
level_data='true'; % Level data relative to the mean sea level of 30 days.
original_stime='false'; % Return the stime not corrected by sensor rate.
filter_out_of_range='true'; % Remove out of range values
filter_exceeded_neighbours='true'; % Remove exceeded neighbours values
filter_spikes_via_median='true'; % Remove spikes via median values
filter_flat_line='true'; % Remove flat line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% download and read research-quality sea level data
 % URL of v2 API of SLSMF IOC
api_url='https://api.ioc-sealevelmonitoring.org/v2/research/stations/';
no_of_days=datenum(end_date)-datenum(start_date); % number of days requested
no_of_pages=ceil(no_of_days/days_per_page); % number of pages needed 
for i=1:no_of_pages
    page=i; % current page number requested
    % building the custom USL according to user inputs
    if length(includesensors)>0
    url=[api_url,station_ID,'/sensors/',sensor,...
        '/data?days_per_page=',num2str(days_per_page),...
        '&page=',num2str(page),...
        '&timestart=',start_date,...
        '&timestop=',end_date,...
        '&includesensors%5B%5D=',includesensors,...
        '&level_data=',level_data,...
        '&original_stime=',original_stime,...
        '&filter_out_of_range=',filter_out_of_range,...
        '&filter_exceeded_neighbours=',filter_exceeded_neighbours,...
        '&filter_spikes_via_median=',filter_spikes_via_median,...
        '&filter_flat_line=',filter_flat_line];
    else
        url=[api_url,station_ID,'/sensors/',sensor,...
            '/data?days_per_page=',num2str(days_per_page),...
            '&page=',num2str(page),...
            '&timestart=',start_date,...
            '&timestop=',end_date,...
            '&level_data=',level_data,...
            '&original_stime=',original_stime,...
            '&filter_out_of_range=',filter_out_of_range,...
            '&filter_exceeded_neighbours=',filter_exceeded_neighbours,...
            '&filter_spikes_via_median=',filter_spikes_via_median,...
            '&filter_flat_line=',filter_flat_line];
    end
    % downloading the data
    disp(['downloading page ',num2str(page),'/',num2str(no_of_pages),' of the v2 API data requested'])
    method  = matlab.net.http.RequestMethod.GET;
    header  = matlab.net.http.HeaderField('accept','text/csv','X-Api-Key', api_key);
    request = matlab.net.http.RequestMessage(method, header);
    [resp, complreq, history] = request.send(url);
    % writing the output file(s)
    fid=fopen(['SLSMF_tg_data_pg',num2str(page),'.txt'],'w');
    fprintf(fid,'%s',resp.Body.Data);
    fclose(fid);
    % read the tables back
    if i==1
        S=readtable(['SLSMF_tg_data_pg',num2str(page),'.txt']);
    else
        tmp=readtable(['SLSMF_tg_data_pg',num2str(page),'.txt']);
        S(end+1:end+size(tmp,1),:)=tmp;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% download non-reasearch quality data
% URL of v1 API of SLSMF IOC
api_url='https://ioc-sealevelmonitoring.org/service.php?query=data';
frm='html'; % file format
% building the custom USL according to user inputs
if length(includesensors)>0
    url_link=[api_url,'&code=',num2str(station_ID),...
        '&timestart=',start_date,'T00%3A00',...
        '&timestop=',end_date,'T00%3A00',...
        '&format=',frm,...
        '&includesensors%5B%5D=',includesensors];
else
    url_link=[api_url,'&code=',num2str(station_ID),...
        '&timestart=',start_date,'T00%3A00',...
        '&timestop=',end_date,'T00%3A00',...
        '&format=',frm];
end
% downloading the data
disp('downloading the v1 API data requested')
str=readtable(url_link,FileType="html",NumHeaderLines=1)
SL_data_table.Date=datetime(str{:,1});
SL_data_table.rad = str{:,2};
isn=isnan(SL_data_table.rad);
SL_data_table.Date(isn)=[];
SL_data_table.rad(isn)=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot the results
figure
plot(S.stime,S.slevel,'k','linewidth',1.5)
hold on
plot(SL_data_table.Date,SL_data_table.rad-1.8937,'r--')
legend('QC sea level data','before QC');
title(['data for SLSMF station ID = ',station_ID])
xlabel('date');
ylabel('WL (m)')
grid on