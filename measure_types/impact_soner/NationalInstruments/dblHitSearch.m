function string = dblHitSearch(loadCellData,triggerLevel,toleranceInt)
% % Input:  loadCellData - Load cell data output from hammer test
% %          hitCriteria - Criteria for which double hits should be recorded
% %                        (recomended to use ~0.03)
% %         toleranceInt - Tolerance interval, set to a vector between 1:2 
% %         
% % Output: Displays if a double hit or too soft hit was recorded.

criteriaPosition = find(loadCellData < -triggerLevel);
badRecordValue = 6;
if(size(criteriaPosition,1) > badRecordValue)
    string = fprintf('Bad hit or hit criteria is to strict! ');
else if (isempty(criteriaPosition))
        string = fprintf('No hit was recorded, or hit was not hard enough! ');
    else
        tempCriteriaPosition = criteriaPosition;
        for i = 1 : (size(criteriaPosition,1) - 1)
            if any((criteriaPosition(i + 1) - criteriaPosition(i)) == toleranceInt)
                if (loadCellData(criteriaPosition(i + 1) > loadCellData(criteriaPosition(i))))
                    tempCriteriaPosition(i) = [];
                else
                    tempCriteriaPosition(i + 1) = [];
                end
            end
        end
        
        if (size(tempCriteriaPosition,1) > 1)
            string = fprintf('Double hit found! ');
        end
    end
end