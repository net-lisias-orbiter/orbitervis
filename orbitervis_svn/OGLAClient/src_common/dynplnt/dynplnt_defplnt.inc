//############################################################################//
// Orulex: Dynamic planet defaults for roampl
// Released under GNU General Public License
// Made in 2006-2010 by Artyom Litvinovich
//############################################################################//
procedure def_planet(cp:proampl;nam:string;rad:double);
begin 
 cp^.used:=true;
 cp^.lded:=false;
 cp^.mtex:=true;
 cp^.name:=nam;
 cp^.seed:=3856;
 cp^.firstrun:=true;
 cp^.basck:=false;
 cp^.radius:=rad;
 cp^.levlimit:=min(round(log2(rad/50)),ocfg.levlimit);
 cp^.noilv:=rad/50;
 cp^.maxgenlv:=8;
 cp^.maxcloudgenlv:=8; 
 cp^.noi.seed:=cp.seed;
 cp^.noi.ci:=false;
 cp^.noi.ni:=false;

 cp^.texture_range_factor:=ocfg.texture_range_factor;
 cp^.texture_gen_order:=ocfg.texture_gen_order;

 cp^.deftxn:=0;

 cp^.speccol:=tvec(0,0,0);
 cp^.specpow:=0;
 cp^.ospeccol:=tvec(0,0,0);
 cp^.ospecpow:=0;

 cp^.terid:=-1;
 cp^.aoff:=0;
 cp^.xa:=0;
 cp^.ya:=0;
 cp^.refidx:=ocfg.refidx;
 cp^.texdir:=ocfg.texdir;
 cp^.hmapdir:=ocfg.hmapdir;
 cp^.bhmap.used:=false;

 cp^.maxpolycount:=ocfg.maxpolycount;
 cp^.altitude_limit:=cp.radius*4;
 cp^.blend_limit:=cp^.altitude_limit/4;
 cp^.balancing_time_slice:=ocfg.balancing_time_slice;
 cp^.main_queue_time_slice:=ocfg.main_queue_time_slice;
 cp^.priorities_time_slice:=ocfg.priorities_time_slice;
 cp^.textures_time_slice:=ocfg.textures_time_slice;
 cp^.level_of_global_heightmap:=ocfg.global_heightmap_limit;
 cp^.glhmop:=3;
 cp^.glhmtr:=0;
 cp^.sbcrlev:=500;

 cp^.bels:=false;
 cp^.tfuncs:='1';
 cp^.tfuncc:=compexpr(cp^.tfuncs);
 cp^.level_of_global_heightmap:=0;

 setlength(cp^.craters,0);
 cp^.cratercnt:=0;
end;
//############################################################################//
