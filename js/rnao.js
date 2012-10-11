function Check(form)
{
    if ( ValidateTargetPDBs() )
    {
        if (ValidateRNAO() )
        {
        	return true;
        }	
    }    
    
    return false;
}    

function EnableSubmit()
{
    document.getElementById('submit').disabled = false;
    document.getElementById('submit').focus();                    
}

function ValidateRNAO()
{
    var rnao = document.getElementById('rnao_input');
    if ( rnao.value.length > 0 )
    {
        return true;
    }
    else
    {
        alert("Problem with RNAO query");
        return false;
    }
    
}

function ValidateTargetPDBs()
{
    var PDBs = document.getElementById('SelectElem');
    if ( PDBs.selectedIndex == -1 ) 
    {
        alert("No target files selected");
        PDBs.focus();  
        return false;       
    }          
    else
    {
        return true;
    }        
}    

function ResetAll() 
{
    document.getElementById("SelectElem").selectedIndex = -1;
    document.getElementById("rnao_input").value = '';    
    document.getElementById("email").value = "";    
    document.getElementById('submit').disabled = true;
}    

function Tloop()
{
	ResetAll();
    document.getElementById("SelectElem").value = "3I8I";
    var html = "x instance_of T_loop iff there exist nt1, nt2, nt3, nt4, nt5 such that:\n\
nt1 cov_conn_3'_5' nt2\n\
nt2 cov_conn_3'_5' nt3\n\
nt3 cov_conn_3'_5' nt4\n\
nt4 cov_conn_3'_5' nt5\n\
nt1 pairs_with_tWH nt5\n\
nt2 bonds with OP2 of nt5\n\
nt1 stack_3'_5' nt2\n\
nt3 stack_3'_5' nt4\n\
nt2 instance_of Guanine or nt2 instance_of Uracil\n\
nt4 instance_of Purine\n\
nt5 instance_of Adenosine\n\
suite of nt1 and nt2 has conformer 1a\n\
suite of nt2 and nt3 has conformer 1g\n\
suite of nt3 and nt4 has conformer 1a\n\
suite of nt4 and nt5 has conformer 1[\n\
x sum_of_collection (nt1,nt2,nt3,nt4,nt5).";

    document.getElementById("rnao_input").value = html;
    EnableSubmit();
}