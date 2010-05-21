//############################################################################//
unit raleydata;
interface
uses maths;  
//############################################################################// 
const 
TRANSMITTANCE_W=256;
TRANSMITTANCE_H=64;

SKY_W=64;
SKY_H=16;

RES_R=32;
RES_MU=128;
RES_MU_S=32;
RES_NU=8;

Rg=6360; 
Rt=6420;
RL=6421;   

IiSun=100;
HR=8;
betaR:vec=(x:0.0058;y:0.0135;z:0.0331);
//betaR:vec=(x:0.001;y:0.0025;z:0.006);
//betaR:vec=(x:0.0010;y:0.0006;z:0.0003);
{   
//Cloudy?
HM=3; 
sc=0.003;
betaMSca:vec=(x:sc;y:sc;z:sc);
betaMEx:vec=(x:sc/0.9;y:sc/0.9;z:sc/0.9);
mieG=0.65;
}
HM=1.2;
sc=0.004;
betaMSca:vec=(x:sc;y:sc;z:sc);
betaMEx:vec=(x:sc/0.9;y:sc/0.9;z:sc/0.9);
mieG=0.8;

TRANSMITTANCE_INTEGRAL_SAMPLES=500;  
INSCATTER_INTEGRAL_SAMPLES=50;

//############################################################################//
implementation   
//############################################################################//
begin
end.   
//############################################################################//
