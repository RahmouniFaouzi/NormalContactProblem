function [Force_Contact,Stifness_Contact]= Contact_Process(XYZ,...
    ELXYM,NEQ,OMEGAN,LTAN,Tool_Ad)
%==========================================
% email : rahmounifaouzi01@gmail.com
% =========================================

global DISPDD 
node_previous = zeros(size(XYZ,1)+3,2);
node_previous(4:end,:) = XYZ;
XYZ = XYZ + reshape(DISPDD,2,length(DISPDD)/2)';

% Search Process Using Boxes
node_positions = [ELXYM.second   ; XYZ ];
nodes_master=1:size(ELXYM.Elemen_con,1)+1;
for ii=1:size(XYZ,1)
    if ii==size(XYZ,1),continue;end
    slave_nodes(1)=4;
    slave_nodes(ii+1)=4+ii;% matrice conectivity for nodes
end
segment_positions = gather_segment_positions(node_positions,...
    ELXYM.Elemen_con); % segment coordinates
%------------------------------------------------------------
KL = Bucketsort(node_positions, segment_positions,...      % BucketSort Methods
    nodes_master, slave_nodes);  
%------------------------------------------------------------
%------------------------------------------------------------
% KL = All_To_All(node_positions, node_previous,...% All To All Methods
%     slave_nodes, segment_positions);
% %------------------------------------------------------------

% Contact Loop
Stifness_Contact   = zeros(NEQ,NEQ);
Force_Contact      = zeros(NEQ,1);

for i = 1 : length(KL)
    for ii = 1:length(nodes_master)-1
        if ii == 1
            Loc  = [XYZ(KL(i),:)',ELXYM.second(ii,:)',ELXYM.second(ii+1,:)'];
        else
            Loc  = [XYZ(KL(i),:)',ELXYM.second(ii+1,:)',ELXYM.second(ii,:)'];
        end
        
        [Force ,STIFF] = Normal_contact(OMEGAN,Loc,LTAN,XYZ,KL(i),Tool_Ad,ii);
        close all
        if isempty(Force) && isempty(STIFF), continue; end

        Force_Contact(KL(i)*2-1:KL(i)*2)  =  Force_Contact(KL(i)*2-1:KL(i)*2) + Force;
        Stifness_Contact(KL(i)*2-1:KL(i)*2 , KL(i)*2-1:KL(i)*2)=...
            Stifness_Contact(KL(i)*2-1:KL(i)*2 , KL(i)*2-1:KL(i)*2)+ STIFF;
        break;
    end
end
end