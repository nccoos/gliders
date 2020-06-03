function decdeg=ddmm2decdeg(ddmm);

dd=fix(ddmm/100); mm=ddmm-100*dd; decdeg=dd+mm/60;

