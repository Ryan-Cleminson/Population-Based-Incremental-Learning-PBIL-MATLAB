%%%%%%%%%%%%%%%%%%%%%%
%   INITIALISATION   %
%%%%%%%%%%%%%%%%%%%%%%
EpochSize = 200; % Number of dtrials within the Epoch
TrialLength = 36;
PV = 0.5*ones(1,TrialLength); % Initial probability vector to generate random numbers
PVPrecision = 0.001; % The rate which the program can determine the best cost with respect to accuracy
Terminals = 12; % Number of terminals in the cost table
MinCost = 0; % Initialisation of minCost
TestNum = 2000; % Number of Times to Test the Large Sample solution
Constraint = 7; % Max number of Terminals each concentrator can handle
Incrementer = 1; % Initialisation of Incrementer which is an index
FinalCost = zeros(1,TestNum-1); % Initialisation of FinalCost which is a ...
                                % matrix of all the costs to determine the best cost

CostTable = xlsread('CostTable.xlsx'); %Imports the Cost Table Provided
CostTable(1,:) = [];
CostTable(:,1) = [];
CostTable;

TrialBin2Dec = @(CostIndexBin) ...        % This is an anonymous function to .. 
                CostIndexBin(1)*4 + ...   % convert 3 binary bits into a decimal number
                CostIndexBin(2)*2 + ...
                CostIndexBin(3)*1;
            
%%%%%%%%%%%%%%%%%%%%
%   MAIN PROGRAM   %
%%%%%%%%%%%%%%%%%%%%
                                
while Incrementer <= TestNum 
    
    Epoch = rand(EpochSize, 36) <= PV; % Generation of Random Epoch
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   SAMPLES + BINTODEC + MINCOST CALCS   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for index = 1:EpochSize % To check each sample(Trial)
        
        Trial = Epoch(index,:); % trialSample takes trial 'index'
        DecimalOut = zeros(1,12); % Initialisation of DecimalOut
        individualTrialMatrix = reshape(Trial,3,12);
        
        for index2 = 1:Terminals
            DecimalOut(index2) = TrialBin2Dec(individualTrialMatrix(:,index2));
        end
        
        flag = 1; % Initiallises Flag to activate the calculations of cost
        
        uniqueNums = unique(DecimalOut); % uniqueNums = each concentrator num produced by the sample
        numOccurences = histc(DecimalOut(:), uniqueNums); % Number of times each concentrator num is produced
        
        
        if numOccurences > Constraint % Ensures that no consentrator has more ...
                                 % than 3 terminals assigned to it              
            flag = 0;
            break;
        end
        
        
        if flag == 1 % Ensures that flag is not 0
            
            Cost = 0; % Initiallises Cost
            
            for index4 = 1:1:Terminals
                Cost = Cost + CostTable(DecimalOut(index4)+1,index4); % Calculates the Cost
            end
            
            if ~MinCost % To initialise the minimum cost if it hasnt been before
     
                MinCost = Cost; % Assigns the minimum cost with the first cost
                pos = index; % Saves the position of the minimum cost
            elseif Cost < MinCost
                MinCost = Cost; % Assigns the minimum cost with the cost produced if its lower
                pos = index; % Saves the position of the minimum cost
                
            end
            
        end
        MinCost
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   LEARNING RATE CHANGE   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for index5 = 1:TrialLength
        
        if Epoch(pos,index5) == 1 
            
            if PV(index5) + PVPrecision < 1 % Checks to ensure that the PV doesnt go above 1
                PV(index5) = PV(index5) + PVPrecision; % Increases the Probabilty Vector
            end
        else
            if PV(index5) - PVPrecision > 0 % Checks to ensure that the PV doesnt go below 0
                PV(index5) = PV(index5) - PVPrecision; % Decreases the Probabilty Vector
            end
            
        end
        
    end
    
   
    %%%%%%%%%%%%%%%%%%%%%%%
    %   FINAL VARIABLES   %
    %%%%%%%%%%%%%%%%%%%%%%%
    FinalCost(Incrementer) = MinCost; % Places the minimum cost of the test into an ...
                                      % array element to check the overall final minimum cost
    %MinCost % Prints minimum costs
    MinCost = 0; % Resets the minimum cost to zero for the next test
    FinalMin = Epoch(pos,:); % FinalMin is loaded from the Epoch that ...
                             % produced the minimum cost outcome
                           
    Incrementer = Incrementer + 1; % Increments the incrementer for each test
    
    
    index = 1:1:(TestNum);
    figure(1)
    plot(FinalCost)
   
end




