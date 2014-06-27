function eventI = find_events(event_key,domain,kind,number,output)
% eventI = find_events(event_key,domain,kind,number,output)
%
% Find the events in event_key that correspond to the domain, kind
% ('transition' or 'other'), function number, and output index specified

	% make sure 'kind' is specified correctly
	assert(~isempty(strfind({'transition','other'},kind)),' ''kind'' should be either ''transition'' or ''other''');

	eventI = strcmp(domain,event_key(:,5)) & strcmp(kind,event_key(:,1)) & ...
		(cat(1,event_key{:,2}) == number) & (cat(1,event_key{:,3}) == output);

end