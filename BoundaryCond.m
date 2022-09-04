function SDISPT = BoundaryCond(bottomNodes,rightNodes,leftNodes,topNodes,A,B,C,D)

SDISPT =[]; nn = 0;
if A ==1 || A==2
    if A==1
        SDISPT(nn+1:nn+size(bottomNodes,2),:)=zeros(size(bottomNodes,2),3);
    else
        SDISPT(nn+1:nn+size(bottomNodes,2)*2,:)=zeros(size(bottomNodes,2)*2,3);
    end
    ji=nn+1;
    for i=1:size(bottomNodes,2)% leftnodes for fixe boundary condition
        JI=bottomNodes(i);
        if A==1
            SDISP(1,:)=[JI 1 0];
            SDISPT(ji,:)=SDISP(1,:);
            ji=ji+1;
        else
            SDISP(1,:)=[JI 1 0];
            SDISP(2,:)=[JI 2 0];
            SDISPT(ji:ji+1,:)=SDISP(1:2,:);
            ji=ji+2;
        end
    end
end
if ~isempty(SDISPT),nn= size(SDISPT,1);end
if B ==1 || B==2
    if B==1
        SDISPT(nn+1:nn+size(rightNodes,2),:)=zeros(size(rightNodes,2),3);
    else
        SDISPT(nn+1:nn+size(rightNodes,2)*2,:)=zeros(size(rightNodes,2)*2,3);
    end
    ji=nn+1;
    for i=1:size(rightNodes,2)% leftnodes for fixe boundary condition
        JI=rightNodes(i);
        if B==1
            SDISP(1,:)=[JI 1 0];
            SDISPT(ji,:)=SDISP(1,:);
            ji=ji+1;
        else
            SDISP(1,:)=[JI 1 0];
            SDISP(2,:)=[JI 2 0];
            SDISPT(ji:ji+1,:)=SDISP(1:2,:);
            ji=ji+2;
        end
    end
end
if ~isempty(SDISPT),nn= size(SDISPT,1);end
if C ==1 || C==2
    if C==1
        SDISPT(nn+1:nn+size(leftNodes,2),:)=zeros(size(leftNodes,2),3);
    else
        SDISPT(nn+1:nn+size(leftNodes,2)*2,:)=zeros(size(leftNodes,2)*2,3);
    end
    ji=nn+1;
    for i=1:size(leftNodes,2)% leftnodes for fixe boundary condition
        JI=leftNodes(i);
        if C==1
            SDISP(1,:)=[JI 1 0];
            SDISPT(ji,:)=SDISP(1,:);
            ji=ji+1;
        else
            SDISP(1,:)=[JI 1 0];
            SDISP(2,:)=[JI 2 0];
            SDISPT(ji:ji+1,:)=SDISP(1:2,:);
            ji=ji+2;
        end
    end
end
if ~isempty(SDISPT),nn= size(SDISPT,1);end
if D ==1 || D==2
    if D==1
        SDISPT(nn+1:nn+size(topNodes,2),:)=zeros(size(topNodes,2),3);
    else
        SDISPT(nn+1:nn+size(topNodes,2)*2,:)=zeros(size(topNodes,2)*2,3);
    end
    ji=nn+1;
    for i=1:size(topNodes,2)% leftnodes for fixe boundary condition
        JI=topNodes(i);
        if D==1
            SDISP(1,:)=[JI 1 0];
            SDISPT(ji,:)=SDISP(1,:);
            ji=ji+1;
        else
            SDISP(1,:)=[JI 1 0];
            SDISP(2,:)=[JI 2 0];
            SDISPT(ji:ji+1,:)=SDISP(1:2,:);
            ji=ji+2;
        end
    end
end
SDISPT = unique(SDISPT,'rows','stable');
end