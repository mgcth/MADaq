%   Author:     Kent Stark Olsen <kent.stark.olsen@gmail.com>
%   Created:    04-04-2013

function [ id, company ] = openPubList( filename )

    %   Get raw data
    f = fopen(filename);
    raw = textscan(f, '%s%s%s%s', 'Delimiter', ',', 'CollectOutput', 1);
    fclose(f);

    %   Clean up and parse data
    j = 1;
    id = [];
    company = {};
    
    for i = 1:length(raw{1,1})
        idTag = raw{1,1}{i, 1};
                
        if (strcmp(idTag(2), 'x'))      %   Format from file is 0xa1f3 as manufacturer ID
          id(j) = hex2dec(idTag(3:6));  %   Convert id to radix 10
          company(j) = cellstr([raw{1,1}{i, 2}, ' ', raw{1,1}{i, 3}, ' ', raw{1,1}{i, 4}]);  %   Store company name as well
          
          j = j + 1;
        end
    end
    
    %   Return data (id and company vectors)
end

