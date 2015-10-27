
#if (_MSC_VER >= 1600)
#define __STDC_UTF_16__
#include <yvals.h>
#endif
#include "mex.h"
#include <vector>
#include <iostream>
#include "string.h"
using namespace std;
typedef float FLOATTYPE;
void HeapAdjustMin(FLOATTYPE array[], FLOATTYPE index[], int i, int Length)
{
    int child;  
    FLOATTYPE temp,tempindex;
    temp=array[i];
    tempindex = index[i];
    for(;2*i+1<Length;i=child)
    {
        
        child = 2*i+1;
        if(child<Length-1 && array[child+1]<array[child])
            child++;
        if (temp>array[child])
        {
            array[i]=array[child];
            index[i] = index[child];
        }
        else
            break;
        array[child]=temp;
        index[child] = tempindex;
        
    }
}
void HeapAdjustMax(FLOATTYPE array[], FLOATTYPE index[], int i, int Length)
{
    int child;
    FLOATTYPE temp,tempindex;
    temp=array[i];
    tempindex = index[i];
    for(;2*i+1<Length;i=child)
    {
        
        child = 2*i+1;
        if(child<Length-1 && array[child+1]>array[child])
            child++;
        if (temp<array[child])
        {
            array[i]=array[child];
            index[i] = index[child];
        }
        else
            break;
        array[child]=temp;
        index[child] = tempindex;
    }
}
void Swap(FLOATTYPE * a,FLOATTYPE * b)
{
    FLOATTYPE temp;
    temp = *a;
    *a = *b;
    *b = temp;
}

FLOATTYPE GetMin(FLOATTYPE array[],FLOATTYPE index[], int Length )
{
    FLOATTYPE minval=index[0];
    Swap(&array[0],&array[Length-1]);
    Swap(&index[0],&index[Length-1]);
    
    int child;
    FLOATTYPE temp, tempindex;
    int i=0;
    temp=array[0];
    tempindex = index[0];
    for (; 2*i+1<Length;i=child)
    {
        child = 2*i+1;
        if(child>=Length-1) break;
        if(child<Length-2 && array[child+1]<array[child])
            child++;
        if (temp>array[child])
        {
            array[i]=array[child];
            index[i] = index[child];
        }
        else
            break;
        array[child]=temp;
        index[child] = tempindex;
    }
    
    return minval;
}
FLOATTYPE GetMax(FLOATTYPE array[],FLOATTYPE index[], int Length )
{
    FLOATTYPE maxval=index[0];
    Swap(&array[0],&array[Length-1]);
    Swap(&index[0],&index[Length-1]);
    
    int child;
    FLOATTYPE temp, tempindex;
    int i=0;
    temp=array[0];
    tempindex = index[0];
    for (; 2*i+1<Length;i=child)
    {
        child = 2*i+1;
        if(child>=Length-1) break;
        if(child<Length-2 && array[child+1]>array[child])
            child++;
        if (temp<array[child])
        {
            array[i]=array[child];
            index[i] = index[child];
        }
        else
            break;
        array[child]=temp;
        index[child] = tempindex;
    }
    
    return maxval;
}

void Kmin(FLOATTYPE array[] , FLOATTYPE index[], int Length , int k)
{
    for(int i=Length/2-1;i>=0;--i)
        HeapAdjustMin(array,index, i,Length);
    FLOATTYPE *ord = new FLOATTYPE[k];
    int j=Length;
    
    for(int i=0;i<k;++i,--j)
    {
        ord[i] =GetMin(array,index,j );
    }
    for(int i = 0;i<k;i++)
        index[i] = ord[i];
    delete[]ord;
}
void Kmax(FLOATTYPE array[] , FLOATTYPE index[], int Length , int k)
{
    for(int i=Length/2-1;i>=0;--i)
        HeapAdjustMax(array,index, i,Length);
    FLOATTYPE *ord = new FLOATTYPE[k];
    int j=Length;
    
    for(int i=0;i<k;++i,--j)
    {
        ord[i] =GetMax(array,index,j );
    }
    for(int i = 0;i<k;i++)
        index[i] = ord[i];
    delete[]ord;
}
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    try{
//        cout<<"MaxHeapsort mex..."<<endl;
        //parsing PatchLowList prhs[0];
        FLOATTYPE *pdata = (float *)mxGetPr(prhs[0]);
        int n_col = mxGetM(prhs[0]);            //19000
        int n_row = mxGetN(prhs[0]);            //6048
        cout<<n_row<<" "<<n_col<<endl;
        //parsing Hogcandnum prhs[1];
        double *pCandnum = (double *)mxGetPr(prhs[1]);
        int Candnum = *pCandnum;
        //parsing order prhs[2];
        double *porder = (double *)mxGetPr(prhs[2]);
        int order = *porder;
        
        //create output array
        plhs[0] = mxCreateNumericMatrix(Candnum, n_row, mxSINGLE_CLASS, mxREAL);
        FLOATTYPE *poutindex = (FLOATTYPE *)mxGetPr(plhs[0]);
//         plhs[1] = mxCreateNumericMatrix(Candnum, n_row, mxSINGLE_CLASS, mxREAL);
//         FLOATTYPE *poutvalue = (FLOATTYPE *)mxGetPr(plhs[0]);
        
        FLOATTYPE *index1_N = new FLOATTYPE[n_col];
//         
        vector<FLOATTYPE> value,index;
        for(int i=0;i<n_row;i++)
        {
            for(int j = 0; j < n_col; j++)
                index1_N[j] = j+1;
            order==0?
                Kmin(pdata+i*n_col,index1_N, n_col, Candnum):
                Kmax(pdata+i*n_col,index1_N, n_col, Candnum);
                memcpy(poutindex+i*Candnum,index1_N,Candnum*sizeof(FLOATTYPE));
           printf("%d/%d done\n",i,n_row);
        }
        delete[] index1_N;
        /**/
    }
    catch(std::exception e)
    {
    }
} 

