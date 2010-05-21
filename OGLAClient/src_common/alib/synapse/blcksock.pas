//############################################################################//
{$DEFINE ONCEWINSOCK}
{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}
{$IFDEF VER125}{$DEFINE BCB}{$ENDIF}
{$IFDEF BCB}{$ObjExportAll On}{$ENDIF}
{$Q-}{$H+}{$M+}  
//############################################################################//
unit blcksock;
interface
uses SysUtils,Classes,synafpc,synsock,synautil,synacode,synaip;
//############################################################################//
const
SynapseRelease='38';
cLocalhost='127.0.0.1';
cAnyHost='0.0.0.0';
cBroadcast='255.255.255.255';
c6Localhost='::1';
c6AnyHost='::0';
c6Broadcast='ffff::1';
cAnyPort='0';
CR=#$0d;
LF=#$0a;
CRLF=CR+LF;
c64k=65536;
//############################################################################//
type
 ESynapseError=class(Exception)
 private
  FErrorCode:integer;
  FErrorMessage:string;
 published
  property ErrorCode:integer read FErrorCode Write FErrorCode;
  property ErrorMessage:string read FErrorMessage Write FErrorMessage;
 end;

 //Types of OnStatus events
 THookSocketReason=(
  {:Resolving is begin. Resolved IP and port is in parameter in format like:
   'localhost.somewhere.com:25'.}
  HR_ResolvingBegin,
  {:Resolving is done. Resolved IP and port is in parameter in format like:
   'localhost.somewhere.com:25'. It is always same as in HR_ResolvingBegin!}
  HR_ResolvingEnd,
  {:Socket created by CreateSocket method. It reporting Family of created
   socket too!}
  HR_SocketCreate,
  //Socket closed by CloseSocket method.
  HR_SocketClose,
  //Socket binded to IP and Port. Binded IP and Port is in parameter in format like:'localhost.somewhere.com:25'.
  HR_Bind,
  //Socket connected to IP and Port. Connected IP and Port is in parameter in format like:'localhost.somewhere.com:25'.
  HR_Connect,
  //Called when CanRead method is used with @true result.
  HR_CanRead,
  //Called when CanWrite method is used with @true result.
  HR_CanWrite,
  //Socket is swithed to Listen mode. (TCP socket only)
  HR_Listen,
  //Socket Accepting client connection. (TCP socket only)
  HR_Accept,
  //report count of bytes readed from socket. Number is in parameter string. If you need is in integer,you must use StrToInt function!
  HR_ReadCount,
  //report count of bytes writed to socket. Number is in parameter string. If you need is in integer,you must use StrToInt function!
  HR_WriteCount,
  //If is limiting of bandwidth on,then this reason is called when sending or receiving is stopped for satisfy bandwidth limit. Parameter is count of waiting milliseconds.
  HR_Wait,
  //report situation where communication error occured. When raiseexcept is @true,then exception is called after this Hook reason.}
  HR_Error
 );

 THookSocketStatus=procedure(Sender:TObject;Reason:THookSocketReason;const Value:string) of object;
 THookDataFilter=procedure(Sender:TObject;var Value:string) of object;
 THookCreateSocket=procedure(Sender:TObject) of object;
 THookMonitor=procedure(Sender:TObject;Writing:Boolean;const buffer:TMemory;len:integer) of object;
 THookAfterConnect=procedure(Sender:TObject) of object;
 THookHeartbeat=procedure(Sender:TObject) of object;

 TSocketFamily=(SF_Any,SF_IP4,SF_IP6);
 TSocksType=(ST_Socks5,ST_Socks4);
 TSynaOptionType=(SOT_Linger,SOT_Recvbuff,SOT_Sendbuff,SOT_NonBlock,SOT_RecvTimeout,SOT_SendTimeout,SOT_Reuse,SOT_TTL,SOT_Broadcast,SOT_MulticastTTL,SOT_MulticastLoop);

 TSynaOption=class(TObject)
 public
  Option:TSynaOptionType;
  Enabled:Boolean;
  Value:integer;
 end;
//############################################################################//
 TBlockSocket=class(TObject)
  private
   FOnStatus:THookSocketStatus;
   FOnReadFilter:THookDataFilter;
   FOnCreateSocket:THookCreateSocket;
   FOnMonitor:THookMonitor;
   FOnHeartbeat:THookHeartbeat;
   FLocalSin:TVarSin;
   FRemoteSin:TVarSin;
   FTag:integer;
   Fbuffer:string;
   FRaiseExcept:Boolean;
   FNonBlockMode:Boolean;
   FMaxLinelength:integer;
   FMaxSendBandwidth:integer;
   FNextSend:LongWord;
   FMaxRecvBandwidth:integer;
   FNextRecv:LongWord;
   FConvertLineEnd:Boolean;
   FLastCR:Boolean;
   FLastLF:Boolean;
   FBinded:Boolean;
   FFamily:TSocketFamily;
   FFamilySave:TSocketFamily;
   FIP6used:Boolean;
   FPreferIP4:Boolean;
   FDelayedOptions:TList;
   FInterPacketTimeout:Boolean;
   FFDset:TFDset;
   FRecvCounter:integer;
   FSendCounter:integer;
   FSendMaxChunk:integer;
   FStopFlag:Boolean;
   FNonblockSendTimeout:integer;
   FHeartbeatRate:integer;
   function GetSizeRecvbuffer:integer;
   procedure setSizeRecvbuffer(Size:integer);
   function GetSizeSendbuffer:integer;
   procedure setSizeSendbuffer(Size:integer);
   procedure setNonBlockMode(Value:Boolean);
   procedure setTTL(TTL:integer);
   function GetTTL:integer;
   procedure setFamily(Value:TSocketFamily);virtual;
   procedure setSocket(Value:TSocket);virtual;
   function GetWsaData:TWSAData;
   function FamilyToAF(f:TSocketFamily):TAddrFamily;
  protected
   FSocket:TSocket;
   FLastError:integer;
   FLastErrorDesc:string;
   procedure setDelayedOption(const Value:TSynaOption);
   procedure DelayedOption(const Value:TSynaOption);
   procedure ProcessDelayedOptions;
   procedure InternalCreateSocket(Sin:TVarSin);
   procedure setSin(var Sin:TVarSin;IP,Port:string);
   function GetSinIP(Sin:TVarSin):string;
   function GetSinPort(Sin:TVarSin):integer;
   procedure DoStatus(Reason:THookSocketReason;const Value:string);
   procedure DoReadFilter(buffer:TMemory;var len:integer);
   procedure DoMonitor(Writing:Boolean;const buffer:TMemory;len:integer);
   procedure DoCreateSocket;
   procedure DoHeartbeat;
   procedure LimitBandwidth(length:integer;MaxB:integer;var Next:LongWord);
   procedure setBandwidth(Value:integer);
   function TestStopFlag:Boolean;
   procedure InternalSendStream(const Stream:TStream;WithSize,Indy:boolean);virtual;
   function InternalCanRead(Timeout:integer):Boolean;virtual;
  public
   constructor Create;
   constructor CreateAlternate(Stub:string);
   destructor Destroy;override;
  
   procedure CreateSocket;
   procedure CreateSocketByName(const Value:string);
   procedure CloseSocket;virtual;
   procedure AbortSocket;virtual;
   procedure Bind(IP,Port:string);
   procedure Connect(IP,Port:string);virtual;
   function Sendbuffer(buffer:Tmemory;length:integer):integer;virtual;
   procedure SendByte(Data:Byte);virtual;
   procedure Sendstring(Data:Ansistring);virtual;
   procedure Sendinteger(Data:integer);virtual;
   procedure SendBlock(const Data:Ansistring);virtual;
   procedure SendStreamRaw(const Stream:TStream);virtual;
   procedure SendStream(const Stream:TStream);virtual;
   procedure SendStreamIndy(const Stream:TStream);virtual;
   function Recvbuffer(buffer:TMemory;length:integer):integer;virtual;
   function RecvbufferEx(buffer:Tmemory;len:integer;Timeout:integer):integer;virtual;
   function RecvbufferStr(length:integer;Timeout:integer):Ansistring;virtual;
   function RecvByte(Timeout:integer):Byte;virtual;
   function Recvinteger(Timeout:integer):integer;virtual;
   function Recvstring(Timeout:integer):Ansistring;virtual;
   function RecvTerminated(Timeout:integer;const Terminator:Ansistring):Ansistring;virtual;
   function RecvPacket(Timeout:integer):Ansistring;virtual;
   function RecvBlock(Timeout:integer):Ansistring;virtual;
   procedure RecvStreamRaw(const Stream:TStream;Timeout:integer);virtual;
   procedure RecvStreamSize(const Stream:TStream;Timeout:integer;Size:integer);
   procedure RecvStream(const Stream:TStream;Timeout:integer);virtual;
   procedure RecvStreamIndy(const Stream:TStream;Timeout:integer);virtual;
   function Peekbuffer(buffer:TMemory;length:integer):integer;virtual;
   function PeekByte(Timeout:integer):Byte;virtual;
   function WaitingData:integer;virtual;
   function WaitingDataEx:integer;
   procedure Purge;
   procedure setLinger(Enable:Boolean;Linger:integer);
   procedure GetSinLocal;
   procedure GetSinRemote;
   procedure GetSins;
   procedure ResetLastError;
   function SockCheck(Sockresult:integer):integer;virtual;
   procedure ExceptCheck;
   function LocalName:string;
   procedure ResolveNameToIP(Name:string;const IPList:Tstrings);
   function ResolveName(Name:string):string;
   function ResolveIPToName(IP:string):string;
   function ResolvePort(Port:string):Word;
   procedure setRemoteSin(IP,Port:string);
   function GetLocalSinIP:string;virtual;
   function GetRemoteSinIP:string;virtual;
   function GetLocalSinPort:integer;virtual;
   function GetRemoteSinPort:integer;virtual;
   function CanRead(Timeout:integer):Boolean;virtual;
   function CanReadEx(Timeout:integer):Boolean;virtual;
   function CanWrite(Timeout:integer):Boolean;virtual;
   function SendbufferTo(buffer:TMemory;length:integer):integer;virtual;
   function RecvbufferFrom(buffer:TMemory;length:integer):integer;virtual;
   function GroupCanRead(const SocketList:TList;Timeout:integer;const CanReadList:TList):Boolean;
   procedure EnableReuse(Value:Boolean);
   procedure setTimeout(Timeout:integer);
   procedure setSendTimeout(Timeout:integer);
   procedure setRecvTimeout(Timeout:integer);
   function GetSocketType:integer;Virtual;
   function GetSocketProtocol:integer;Virtual;
   property WSAData:TWSADATA read GetWsaData;
   property LocalSin:TVarSin read FLocalSin write FLocalSin;
   property RemoteSin:TVarSin read FRemoteSin write FRemoteSin;
   property Socket:TSocket read FSocket write setSocket;
   property LastError:integer read FLastError;
   property LastErrorDesc:string read FLastErrorDesc;
   property Linebuffer:string read Fbuffer write Fbuffer;
   property SizeRecvbuffer:integer read GetSizeRecvbuffer write setSizeRecvbuffer;
   property SizeSendbuffer:integer read GetSizeSendbuffer write setSizeSendbuffer;
   property NonBlockMode:Boolean read FNonBlockMode Write setNonBlockMode;
   property TTL:integer read GetTTL Write setTTL;
   property IP6used:Boolean read FIP6used;
   property RecvCounter:integer read FRecvCounter;
   property SendCounter:integer read FSendCounter;
  published
   class function GetErrorDesc(ErrorCode:integer):string;
   function GetErrorDescEx:string;virtual;
   property Tag:integer read FTag write FTag;
   property RaiseExcept:Boolean read FRaiseExcept write FRaiseExcept;
   property MaxLinelength:integer read FMaxLinelength Write FMaxLinelength;
   property MaxSendBandwidth:integer read FMaxSendBandwidth Write FMaxSendBandwidth;
   property MaxRecvBandwidth:integer read FMaxRecvBandwidth Write FMaxRecvBandwidth;
   property MaxBandwidth:integer Write setBandwidth;
   property ConvertLineEnd:Boolean read FConvertLineEnd Write FConvertLineEnd;
   property Family:TSocketFamily read FFamily Write setFamily;
   property PreferIP4:Boolean read FPreferIP4 Write FPreferIP4;
   property InterPacketTimeout:Boolean read FInterPacketTimeout Write FInterPacketTimeout;
   property SendMaxChunk:integer read FSendMaxChunk Write FSendMaxChunk;
   property StopFlag:Boolean read FStopFlag Write FStopFlag;
   property NonblockSendTimeout:integer read FNonblockSendTimeout Write FNonblockSendTimeout;
   property OnStatus:THookSocketStatus read FOnStatus write FOnStatus;
   property OnReadFilter:THookDataFilter read FOnReadFilter write FOnReadFilter;
   property OnCreateSocket:THookCreateSocket read FOnCreateSocket write FOnCreateSocket;
   property OnMonitor:THookMonitor read FOnMonitor write FOnMonitor;
   property OnHeartbeat:THookHeartbeat read FOnHeartbeat write FOnHeartbeat;
   property HeartbeatRate:integer read FHeartbeatRate Write FHeartbeatRate;
 end;
//############################################################################//
 TSocksBlockSocket=class(TBlockSocket)
  protected
   FSocksIP:string;
   FSocksPort:string;
   FSocksTimeout:integer;
   FSocksUsername:string;
   FSocksPassword:string;
   FUsingSocks:Boolean;
   FSocksResolver:Boolean;
   FSocksLastError:integer;
   FSocksResponseIP:string;
   FSocksResponsePort:string;
   FSocksLocalIP:string;
   FSocksLocalPort:string;
   FSocksRemoteIP:string;
   FSocksRemotePort:string;
   FBypassFlag:Boolean;
   FSocksType:TSocksType;
   function SocksCode(IP,Port:string):string;
   function SocksDecode(Value:string):integer;
  public
   constructor Create;
   function SocksOpen:Boolean;
   function SocksRequest(Cmd:Byte;const IP,Port:string):Boolean;
   function SocksResponse:Boolean;
   property UsingSocks:Boolean read FUsingSocks;
   property SocksLastError:integer read FSocksLastError;
  published
   property SocksIP:string read FSocksIP write FSocksIP;
   property SocksPort:string read FSocksPort write FSocksPort;
   property SocksUsername:string read FSocksUsername write FSocksUsername;
   property SocksPassword:string read FSocksPassword write FSocksPassword;
   property SocksTimeout:integer read FSocksTimeout write FSocksTimeout;
   property SocksResolver:Boolean read FSocksResolver write FSocksResolver;
   property SocksType:TSocksType read FSocksType write FSocksType;
 end;

 TTCPBlockSocket=class(TSocksBlockSocket)
 protected
  FOnAfterConnect:THookAfterConnect;
  FHTTPTunnelIP:string;
  FHTTPTunnelPort:string;
  FHTTPTunnel:Boolean;
  FHTTPTunnelRemoteIP:string;
  FHTTPTunnelRemotePort:string;
  FHTTPTunnelUser:string;
  FHTTPTunnelPass:string;
  FHTTPTunnelTimeout:integer;
  procedure SocksDoConnect(IP,Port:string);
  procedure HTTPTunnelDoConnect(IP,Port:string);
  procedure DoAfterConnect;
 public
  constructor Create;
  destructor Destroy;override;
  function GetErrorDescEx:string;override;
  procedure CloseSocket;override;
  function WaitingData:integer;override;
  procedure Listen;virtual;
  function Accept:TSocket;
  procedure Connect(IP,Port:string);override;
  procedure SSLDoConnect;
  procedure SSLDoShutdown;
  function SSLAcceptConnection:Boolean;
  function GetLocalSinIP:string;override;
  function GetRemoteSinIP:string;override;
  function GetLocalSinPort:integer;override;
  function GetRemoteSinPort:integer;override;
  function Sendbuffer(buffer:TMemory;length:integer):integer;override;
  function Recvbuffer(buffer:TMemory;len:integer):integer;override;
  function GetSocketType:integer;override;
  function GetSocketProtocol:integer;override;
  property HTTPTunnel:Boolean read FHTTPTunnel;
 published
  property HTTPTunnelIP:string read FHTTPTunnelIP Write FHTTPTunnelIP;
  property HTTPTunnelPort:string read FHTTPTunnelPort Write FHTTPTunnelPort;
  property HTTPTunnelUser:string read FHTTPTunnelUser Write FHTTPTunnelUser;
  property HTTPTunnelPass:string read FHTTPTunnelPass Write FHTTPTunnelPass;
  property HTTPTunnelTimeout:integer read FHTTPTunnelTimeout Write FHTTPTunnelTimeout;
  property OnAfterConnect:THookAfterConnect read FOnAfterConnect write FOnAfterConnect;
 end;

 
 TDgramBlockSocket=class(TSocksBlockSocket)
 public
  procedure Connect(IP,Port:string);override;
  function Sendbuffer(buffer:TMemory;length:integer):integer;override;
  function Recvbuffer(buffer:TMemory;length:integer):integer;override;
 end;

 
 TUDPBlockSocket=class(TDgramBlockSocket)
 protected
  FSocksControlSock:TTCPBlockSocket;
  function UdpAssociation:Boolean;
  procedure setMulticastTTL(TTL:integer);
  function GetMulticastTTL:integer;
 public
  destructor Destroy;override;
  procedure EnableBroadcast(Value:Boolean);
  function SendbufferTo(buffer:TMemory;length:integer):integer;override;
  function RecvbufferFrom(buffer:TMemory;length:integer):integer;override;
  procedure AddMulticast(MCastIP:string);
  procedure DropMulticast(MCastIP:string);
  procedure EnableMulticastLoop(Value:Boolean);
  function GetSocketType:integer;override;
  function GetSocketProtocol:integer;override;
  property MulticastTTL:integer read GetMulticastTTL Write setMulticastTTL;
 end;

 
 TICMPBlockSocket=class(TDgramBlockSocket)
 public
  function GetSocketType:integer;override;
  function GetSocketProtocol:integer;override;
 end;

 
 TRAWBlockSocket=class(TBlockSocket)
 public
  function GetSocketType:integer;override;
  function GetSocketProtocol:integer;override;
 end;

 
 TIPHeader=record
  Verlen:Byte;
  TOS:Byte;
  Totallen:Word;
  Identifer:Word;
  FragOffsets:Word;
  TTL:Byte;
  Protocol:Byte;
  CheckSum:Word;
  SourceIp:LongWord;
  DestIp:LongWord;
  Options:LongWord;
 end;

 TSynaClient=Class(TObject)
 protected
  FTargetHost:string;
  FTargetPort:string;
  FIPInterface:string;
  FTimeout:integer;
  FUserName:string;
  FPassword:string;
 public
  constructor Create;
 published
  property TargetHost:string read FTargetHost Write FTargetHost;
  property TargetPort:string read FTargetPort Write FTargetPort;
  property IPInterface:string read FIPInterface Write FIPInterface;
  property Timeout:integer read FTimeout Write FTimeout;
  property UserName:string read FUserName Write FUserName;
  property Password:string read FPassword Write FPassword;
 end;
//############################################################################//
//############################################################################//
implementation
//############################################################################//
//############################################################################//
{$IFDEF ONCEWINSOCK}
var
WsaDataOnce:TWSADATA;
e:ESynapseError;
{$ENDIF}
//############################################################################//
constructor TBlockSocket.Create;begin CreateAlternate('');end;
constructor TBlockSocket.CreateAlternate(Stub:string);
{$IFNDEF ONCEWINSOCK}var e:ESynapseError;{$ENDIF}
begin
 inherited Create;
 FDelayedOptions:=TList.Create;
 FRaiseExcept:=false;
 FSocket:=INVALID_SOCKET;
 Fbuffer:='';
 FLastCR:=false;
 FLastLF:=false;
 FBinded:=false;
 FNonBlockMode:=false;
 FMaxLinelength:=0;
 FMaxSendBandwidth:=0;
 FNextSend:=0;
 FMaxRecvBandwidth:=0;
 FNextRecv:=0;
 FConvertLineEnd:=false;
 FFamily:=SF_Any;
 FFamilySave:=SF_Any;
 FIP6used:=false;
 FPreferIP4:=true;
 FInterPacketTimeout:=true;
 FRecvCounter:=0;
 FSendCounter:=0;
 FSendMaxChunk:=c64k;
 FStopFlag:=false;
 FNonblockSendTimeout:=15000;
 FHeartbeatRate:=0;
{$IFNDEF ONCEWINSOCK}
 if Stub='' then Stub:=DLLStackName;
 if not InitSocketInterface(Stub) then begin
  e:=ESynapseError.Create('Error loading Socket interface ('+Stub+')!');
  e.ErrorCode:=0;
  e.ErrorMessage:='Error loading Socket interface ('+Stub+')!';
  raise e;
 end;
 SockCheck(synsock.WSAStartup(WinsockLevel,FWsaDataOnce));
 ExceptCheck;
{$ENDIF}
end;
//############################################################################//
destructor TBlockSocket.Destroy;
var n:integer;
p:TSynaOption;
begin
 CloseSocket;
{$IFNDEF ONCEWINSOCK}
 synsock.WSACleanup;
 DestroySocketInterface;
{$ENDIF}
 for n:=FDelayedOptions.Count-1 downto 0 do begin
  p:=TSynaOption(FDelayedOptions[n]);
  p.Free;
 end;
 FDelayedOptions.Free;
 inherited Destroy;
end;
//############################################################################//
function TBlockSocket.FamilyToAF(f:TSocketFamily):TAddrFamily;
begin
 case f of
  SF_ip4:result:=AF_INET;
  SF_ip6:result:=AF_INET6;
  else result:=AF_UNSPEC;
 end;
end;
//############################################################################//
procedure TBlockSocket.setDelayedOption(const Value:TSynaOption);
var li:TLinger;
x:integer;
buf:TMemory;
begin
 case value.Option of
  SOT_Linger:begin
  li.l_onoff:=Ord(Value.Enabled);
  li.l_linger:=Value.Value div 1000;
  buf:=@li;
  synsock.setSockOpt(FSocket,integer(SOL_SOCKET),integer(SO_LINGER),buf,SizeOf(li));
  end;
  SOT_Recvbuff:begin
   buf:=@Value.Value;
   synsock.setSockOpt(FSocket,integer(SOL_SOCKET),integer(SO_RCVbuf),buf,SizeOf(Value.Value));
  end;
  SOT_Sendbuff:begin
   buf:=@Value.Value;
   synsock.setSockOpt(FSocket,integer(SOL_SOCKET),integer(SO_SNDbuf),buf,SizeOf(Value.Value));
  end;
  SOT_NonBlock:begin
   FNonBlockMode:=Value.Enabled;
   x:=Ord(FNonBlockMode);
   synsock.IoctlSocket(FSocket,FIONBIO,x);
  end;
  SOT_RecvTimeout:begin
   buf:=@Value.Value;
   synsock.setSockOpt(FSocket,integer(SOL_SOCKET),integer(SO_RCVTIMEO),buf,SizeOf(Value.Value));
  end;
  SOT_SendTimeout:begin
   buf:=@Value.Value;
   synsock.setSockOpt(FSocket,integer(SOL_SOCKET),integer(SO_SNDTIMEO),buf,SizeOf(Value.Value));
  end;
  SOT_Reuse:begin
   x:=Ord(Value.Enabled);
   buf:=@x;
   synsock.setSockOpt(FSocket,integer(SOL_SOCKET),integer(SO_REUSEADDR),buf,SizeOf(x));
  end;
  SOT_TTL:begin
   buf:=@Value.Value;
   if FIP6Used then synsock.setSockOpt(FSocket,integer(IPPROTO_IPV6),integer(IPV6_UNICAST_HOPS),buf,SizeOf(Value.Value))
               else synsock.setSockOpt(FSocket,integer(IPPROTO_IP)  ,integer(IP_TTL),buf,SizeOf(Value.Value));
  end;
  SOT_Broadcast:begin
   x:=Ord(Value.Enabled);
   buf:=@x;
   synsock.setSockOpt(FSocket,integer(SOL_SOCKET),integer(SO_BROADCAST),buf,SizeOf(x));
  end;
  SOT_MulticastTTL:begin
   buf:=@Value.Value;
   if FIP6Used then synsock.setSockOpt(FSocket,integer(IPPROTO_IPV6),integer(IPV6_MULTICAST_HOPS),buf,SizeOf(Value.Value))
               else synsock.setSockOpt(FSocket,integer(IPPROTO_IP),integer(IP_MULTICAST_TTL),buf,SizeOf(Value.Value));
  end;
  SOT_MulticastLoop:begin
   x:=Ord(Value.Enabled);
   buf:=@x;
   if FIP6Used then synsock.setSockOpt(FSocket,integer(IPPROTO_IPV6),integer(IPV6_MULTICAST_LOOP),buf,SizeOf(x))
               else synsock.setSockOpt(FSocket,integer(IPPROTO_IP),integer(IP_MULTICAST_LOOP),buf,SizeOf(x));
  end;
 end;
 value.free;
end;
//############################################################################//
procedure TBlockSocket.DelayedOption(const Value:TSynaOption);
begin
 if FSocket=INVALID_SOCKET then FDelayedOptions.Insert(0,Value) else setDelayedOption(Value);
end;
//############################################################################//
procedure TBlockSocket.ProcessDelayedOptions;
var n:integer;
d:TSynaOption;
begin
 for n:=FDelayedOptions.Count-1 downto 0 do begin
  d:=TSynaOption(FDelayedOptions[n]);
  setDelayedOption(d);
 end;
 FDelayedOptions.Clear;
end;
//############################################################################//
procedure TBlockSocket.setSin(var Sin:TVarSin;IP,Port:string);
var f:TSocketFamily;
begin
 DoStatus(HR_ResolvingBegin,IP+':'+Port);
 ResetLastError;
 //if socket exists,then use their type,else use users selection
 f:=SF_Any;
 if (FSocket=INVALID_SOCKET) and (FFamily=SF_any) then begin
  if IsIP(IP) then f:=SF_IP4 else if IsIP6(IP) then f:=SF_IP6;
 end else f:=FFamily;
 FLastError:=synsock.setVarSin(sin,ip,port,FamilyToAF(f),GetSocketprotocol,GetSocketType,FPreferIP4);
 DoStatus(HR_ResolvingEnd,IP+':'+Port);
end;
//############################################################################//
function TBlockSocket.GetSinIP(Sin:TVarSin):string;begin result:=synsock.GetSinIP(sin);end;
function TBlockSocket.GetSinPort(Sin:TVarSin):integer;begin result:=synsock.GetSinPort(sin);end;
//############################################################################//
procedure TBlockSocket.CreateSocket;
var sin:TVarSin;
begin
 //dummy for SF_Any Family mode
 ResetLastError;
 if (FFamily<>SF_Any) and (FSocket=INVALID_SOCKET) then begin
  FillChar(Sin,Sizeof(Sin),0);
  if FFamily=SF_IP6 then sin.sin_family:=AF_INET6 else sin.sin_family:=AF_INET;
  InternalCreateSocket(Sin);
 end;
end;
//############################################################################//
procedure TBlockSocket.CreateSocketByName(const Value:string);
var sin:TVarSin;
begin
 ResetLastError;
 if FSocket=INVALID_SOCKET then begin
  setSin(sin,value,'0');
  if FLastError=0 then InternalCreateSocket(Sin);
 end;
end;
//############################################################################//
procedure TBlockSocket.InternalCreateSocket(Sin:TVarSin);
begin
 FStopFlag:=false;
 FRecvCounter:=0;
 FSendCounter:=0;
 ResetLastError;
 if FSocket=INVALID_SOCKET then begin
  Fbuffer:='';
  FBinded:=false;
  FIP6Used:=Sin.AddressFamily=AF_INET6;
  FSocket:=synsock.Socket(integer(Sin.AddressFamily),GetSocketType,GetSocketProtocol);
  if FSocket=INVALID_SOCKET then FLastError:=synsock.WSAGetLastError;
  FD_ZERO(FFDset);
  FD_set(FSocket,FFDset);
  ExceptCheck;
  if FIP6used then DoStatus(HR_SocketCreate,'IPv6')
              else DoStatus(HR_SocketCreate,'IPv4');
  ProcessDelayedOptions;
  DoCreateSocket;
 end;
end;
//############################################################################//
procedure TBlockSocket.CloseSocket;begin AbortSocket;end;
//############################################################################//
procedure TBlockSocket.AbortSocket;
var n:integer;
p:TSynaOption;
begin
 if FSocket<>INVALID_SOCKET then synsock.CloseSocket(FSocket);
 FSocket:=INVALID_SOCKET;
 for n:=FDelayedOptions.Count-1 downto 0 do begin
  p:=TSynaOption(FDelayedOptions[n]);
  p.Free;
 end;
 FDelayedOptions.Clear;
 FFamily:=FFamilySave;
 DoStatus(HR_SocketClose,'');
end;
//############################################################################//
procedure TBlockSocket.Bind(IP,Port:string);
var Sin:TVarSin;
begin
 ResetLastError;
 if (FSocket<>INVALID_SOCKET)or not((FFamily=SF_ANY) and (IP=cAnyHost) and (Port=cAnyPort)) then begin
  setSin(Sin,IP,Port);
  if FLastError=0 then begin
   if FSocket=INVALID_SOCKET then InternalCreateSocket(Sin);
   SockCheck(synsock.Bind(FSocket,Sin));
   GetSinLocal;
   Fbuffer:='';
   FBinded:=true;
  end;
  ExceptCheck;
  DoStatus(HR_Bind,IP+':'+Port);
 end;
end;
//############################################################################//
procedure TBlockSocket.Connect(IP,Port:string);
var Sin:TVarSin;
begin
 setSin(Sin,IP,Port);
 if FLastError=0 then begin
  if FSocket=INVALID_SOCKET then InternalCreateSocket(Sin);
  SockCheck(synsock.Connect(FSocket,Sin));
  if FLastError=0 then GetSins;
  Fbuffer:='';
  FLastCR:=false;
  FLastLF:=false;
 end;
 ExceptCheck;
 DoStatus(HR_Connect,IP+':'+Port);
end;
//############################################################################//
procedure TBlockSocket.GetSinLocal;begin synsock.GetSockName(FSocket,FLocalSin);end;
procedure TBlockSocket.GetSinRemote;begin synsock.GetPeerName(FSocket,FRemoteSin);end;
procedure TBlockSocket.GetSins;begin GetSinLocal;GetSinRemote;end;
procedure TBlockSocket.setBandwidth(Value:integer);begin MaxSendBandwidth:=Value;MaxRecvBandwidth:=Value;end;
//############################################################################//
procedure TBlockSocket.LimitBandwidth(length:integer;MaxB:integer;var Next:LongWord);
var x,y:longword;
n:integer;
begin
 if FStopFlag then exit;
 if MaxB>0 then begin
  y:=GetTick;
  if Next>y then begin
   x:=Next-y;
   if x>0 then begin
    DoStatus(HR_Wait,IntToStr(x));
    sleep(x mod 250);
    for n:=1 to x div 250 do if FStopFlag then break else sleep(250);
   end;
  end;
  Next:=GetTick+Trunc((length / MaxB) * 1000);
 end;
end;
//############################################################################//
function TBlockSocket.TestStopFlag:Boolean;
begin
 DoHeartbeat;
 result:=FStopFlag;
 if result then begin
  FStopFlag:=false;
  FLastError:=WSAECONNABORTED;
  ExceptCheck;
 end;
end;
//############################################################################//
function TBlockSocket.Sendbuffer(buffer:TMemory;length:integer):integer;
var x,y,l,r:integer;
p:Pointer;
begin
 result:=0;
 if TestStopFlag then exit;
 DoMonitor(true,buffer,length);
 l:=length;
 x:=0;
 while x<l do begin
  y:=l-x;
  if y>FSendMaxChunk then y:=FSendMaxChunk;
  if y>0 then begin
   LimitBandwidth(y,FMaxSendBandwidth,FNextsend);
   p:=IncPoint(buffer,x);
   r:=synsock.Send(FSocket,p,y,MSG_NOSIGNAL);
   SockCheck(r);
   if FLastError=WSAEWOULDBLOCK then begin
    if CanWrite(FNonblockSendTimeout) then begin
     r:=synsock.Send(FSocket,p,y,MSG_NOSIGNAL);
     SockCheck(r);
    end else FLastError:=WSAETIMEDOUT;
   end;
   if FLastError<>0 then Break;
   Inc(x,r);
   Inc(result,r);
   Inc(FSendCounter,r);
   DoStatus(HR_WriteCount,IntToStr(r));
  end else break;
 end;
 ExceptCheck;
end;
//############################################################################//
procedure TBlockSocket.SendByte(Data:Byte);begin Sendbuffer(@Data,1);end;
procedure TBlockSocket.Sendstring(Data:Ansistring);var buf:TMemory;begin buf:=pchar(data);Sendbuffer(buf,length(Data));end;
procedure TBlockSocket.Sendinteger(Data:integer);var buf:TMemory;begin buf:=@Data;Sendbuffer(buf,SizeOf(Data));end;
procedure TBlockSocket.SendBlock(const Data:Ansistring);begin Sendstring(Codelongint(SwapBytes(length(data)))+Data);end;
//############################################################################//
procedure TBlockSocket.InternalSendStream(const Stream:TStream;WithSize,Indy:boolean);
var si,l,x,y,yr:integer;
s:Ansistring;
b:boolean;
begin
 si:=Stream.Size-Stream.Position;
 if not indy then l:=SwapBytes(si) else l:=si;
 x:=0;
 b:=true;
 while x<si do begin
  y:=si-x;
  if y>FSendMaxChunk then y:=FSendMaxChunk;
  setlength(s,y);
  yr:=Stream.read(Pchar(s)^,y);
  if yr>0 then begin
   setlength(s,yr);
   if WithSize and b then begin
    b:=false;
    Sendstring(CodeLongInt(l)+s);
   end else Sendstring(s);
   if FLastError<>0 then break;
   Inc(x,yr);
  end else break;
 end;
end;
//############################################################################//
procedure TBlockSocket.SendStreamRaw(const Stream:TStream);begin InternalSendStream(Stream,false,false);end;
procedure TBlockSocket.SendStreamIndy(const Stream:TStream);begin InternalSendStream(Stream,true,true);end;
procedure TBlockSocket.SendStream(const Stream:TStream);begin InternalSendStream(Stream,true,false);end;
//############################################################################//
function TBlockSocket.Recvbuffer(buffer:TMemory;length:integer):integer;
begin
 result:=0;
 if TestStopFlag then exit;
 LimitBandwidth(length,FMaxRecvBandwidth,FNextRecv);
 result:=synsock.Recv(FSocket,buffer,length,MSG_NOSIGNAL);
 if result=0 then FLastError:=WSAECONNREset else SockCheck(result);
 ExceptCheck;
 if result>0 then begin
  Inc(FRecvCounter,result);
  DoStatus(HR_ReadCount,IntToStr(result));
  DoMonitor(false,buffer,result);
  DoReadFilter(buffer,result);
 end;
end;
//############################################################################//
function TBlockSocket.RecvbufferEx(buffer:TMemory;len:integer;Timeout:integer):integer;
var s:Ansistring;
rl,l:integer;
ti:LongWord;
begin
 ResetLastError;
 result:=0;
 if len>0 then begin
  rl:=0;
  repeat
   ti:=GetTick;
   s:=RecvPacket(Timeout);
   l:=length(s);
   if (rl+l)>len then l:=len-rl;
   move(Pointer(s)^,IncPoint(buffer,rl)^,l);
   rl:=rl+l;
   if FLastError<>0 then Break;
   if rl >= len then Break;
   if not FInterPacketTimeout then begin
    Timeout:=Timeout-integer(TickDelta(ti,GetTick));
    if Timeout <= 0 then begin
     FLastError:=WSAETIMEDOUT;
     Break;
    end;
   end;
  until false;
  delete(s,1,l);
  Fbuffer:=s;
  result:=rl;
 end;
end;
//############################################################################//
function TBlockSocket.RecvbufferStr(length:integer;Timeout:integer):Ansistring;
var x:integer;
begin
 result:='';
 if length>0 then begin
  setlength(result,length);
  x:=RecvbufferEx(PChar(result),length ,Timeout);
  if FLastError=0 then setlength(result,x)else result:='';
 end;
end;
//############################################################################//
function TBlockSocket.RecvPacket(Timeout:integer):Ansistring;
var x:integer;
begin
 result:='';
 ResetLastError;
 if Fbuffer<>'' then begin
  result:=Fbuffer;
  Fbuffer:='';
 end else begin
  {$IFDEF WIN32}
  //not drain CPU on large downloads...
  Sleep(0);
  {$ENDIF}
  x:=WaitingData;
  if x>0 then begin
   setlength(result,x);
   x:=Recvbuffer(Pointer(result),x);
   if x>=0 then setlength(result,x);
  end else begin
   if CanRead(Timeout) then begin
    x:=WaitingData;
    if x=0 then FLastError:=WSAECONNREset;
    if x>0 then begin
     setlength(result,x);
     x:=Recvbuffer(Pointer(result),x);
     if x>=0 then setlength(result,x);
    end;
   end else FLastError:=WSAETIMEDOUT;
  end;
 end;
 if FConvertLineEnd and (result<>'') then begin
  if FLastCR and (result[1]=LF) then Delete(result,1,1);
  if FLastLF and (result[1]=CR) then Delete(result,1,1);
  FLastCR:=false;
  FLastLF:=false;
 end;
 ExceptCheck;
end;
//############################################################################//
function TBlockSocket.RecvByte(Timeout:integer):Byte;
begin
 result:=0;
 ResetLastError;
 if Fbuffer='' then Fbuffer:=RecvPacket(Timeout);
 if (FLastError=0) and (Fbuffer<>'') then begin
  result:=Ord(Fbuffer[1]);
  Delete(Fbuffer,1,1);
 end;
 ExceptCheck;
end;
//############################################################################//
function TBlockSocket.Recvinteger(Timeout:integer):integer;
var s:Ansistring;
begin
 result:=0;
 s:=RecvbufferStr(4,Timeout);
 if FLastError=0 then result:=(ord(s[1])+ord(s[2]) * 256)+(ord(s[3])+ord(s[4]) * 256) * 65536;
end;
//############################################################################//
function TBlockSocket.RecvTerminated(Timeout:integer;const Terminator:Ansistring):Ansistring;
var x,l,tl:integer;
s,t:Ansistring;
CorCRLF:Boolean;
ti:LongWord;
begin
 ResetLastError;
 result:='';
 l:=length(Terminator);
 if l=0 then exit;
 tl:=l;
 CorCRLF:=FConvertLineEnd and (Terminator=CRLF);
 s:='';
 x:=0;
 repeat
  //get rest of Fbuffer or incomming new data...
  ti:=GetTick;
  s:=s+RecvPacket(Timeout);
  if FLastError<>0 then Break;
  x:=0;
  if length(s)>0 then if CorCRLF then begin
   t:='';
   x:=PosCRLF(s,t);
   tl:=length(t);
   if t=CR then FLastCR:=true;
   if t=LF then FLastLF:=true;
  end else begin
   x:=pos(Terminator,s);
   tl:=l;
  end;
  if (FMaxLinelength<>0) and (length(s)>FMaxLinelength) then begin
   FLastError:=WSAENObufS;
   Break;
  end;
  if x>0 then Break;
  if not FInterPacketTimeout then begin
   Timeout:=Timeout-integer(TickDelta(ti,GetTick));
   if Timeout<=0 then begin
    FLastError:=WSAETIMEDOUT;
    Break;
   end;
  end;
 until false;
 if x>0 then begin
  result:=Copy(s,1,x-1);
  Delete(s,1,x+tl-1);
 end;
 Fbuffer:=s;
 ExceptCheck;
end;
//############################################################################//
function TBlockSocket.Recvstring(Timeout:integer):Ansistring;
var s:Ansistring;
begin
 result:='';
 s:=RecvTerminated(Timeout,CRLF);
 if FLastError=0 then result:=s;
end;
//############################################################################//
function TBlockSocket.RecvBlock(Timeout:integer):Ansistring;
var x:integer;
begin
 result:='';
 x:=Recvinteger(Timeout);
 if FLastError=0 then result:=RecvbufferStr(x,Timeout);
end;
//############################################################################//
procedure TBlockSocket.RecvStreamRaw(const Stream:TStream;Timeout:integer);
var s:Ansistring;
begin
 repeat
  s:=RecvPacket(Timeout);
  if FLastError=0 then WriteStrToStream(Stream,s);
 until FLastError<>0;
end;
//############################################################################//
procedure TBlockSocket.RecvStreamSize(const Stream:TStream;Timeout:integer;Size:integer);
var s:Ansistring;
n:integer;
begin
 for n:=1 to (Size div FSendMaxChunk) do begin
  s:=RecvbufferStr(FSendMaxChunk,Timeout);
  if FLastError<>0 then exit;
  Stream.Write(Pchar(s)^,FSendMaxChunk);
 end;
 n:=Size mod FSendMaxChunk;
 if n>0 then begin
  s:=RecvbufferStr(n,Timeout);
  if FLastError<>0 then exit;
  Stream.Write(Pchar(s)^,n);
 end;
end;
//############################################################################//
procedure TBlockSocket.RecvStreamIndy(const Stream:TStream;Timeout:integer);
var x:integer;
begin
 x:=Recvinteger(Timeout);
 x:=synsock.NToHL(x);
 if FLastError=0 then RecvStreamSize(Stream,Timeout,x);
end;
//############################################################################//
procedure TBlockSocket.RecvStream(const Stream:TStream;Timeout:integer);
var x:integer;
begin
 x:=Recvinteger(Timeout);
 if FLastError=0 then RecvStreamSize(Stream,Timeout,x);
end;
//############################################################################//
function TBlockSocket.Peekbuffer(buffer:TMemory;length:integer):integer;
begin
 result:=synsock.Recv(FSocket,buffer,length,MSG_PEEK+MSG_NOSIGNAL);
 SockCheck(result);
 ExceptCheck;
end;
//############################################################################//
function TBlockSocket.PeekByte(Timeout:integer):Byte;
var s:string;
begin
 result:=0;
 if CanRead(Timeout) then begin
  setlength(s,1);
  Peekbuffer(Pointer(s),1);
  if s<>'' then result:=Ord(s[1]);
 end
 else FLastError:=WSAETIMEDOUT;
 ExceptCheck;
end;
//############################################################################//
procedure TBlockSocket.ResetLastError;begin FLastError:=0;FLastErrorDesc:='';end;
//############################################################################//
function TBlockSocket.SockCheck(Sockresult:integer):integer;
begin
 ResetLastError;
 if Sockresult=integer(SOCKET_ERROR) then begin
  FLastError:=synsock.WSAGetLastError;
  FLastErrorDesc:=GetErrorDescEx;
 end;
 result:=FLastError;
end;
//############################################################################//
procedure TBlockSocket.ExceptCheck;
var e:ESynapseError;
begin
 FLastErrorDesc:=GetErrorDescEx;
 if (LastError<>0) and (LastError<>WSAEINPROGRESS) and (LastError<>WSAEWOULDBLOCK) then begin
  DoStatus(HR_Error,IntToStr(FLastError)+','+FLastErrorDesc);
  if FRaiseExcept then begin
   e:=ESynapseError.Create(Format('Synapse TCP/IP Socket error %d:%s',[FLastError,FLastErrorDesc]));
   e.ErrorCode:=FLastError;
   e.ErrorMessage:=FLastErrorDesc;
   raise e;
  end;
 end;
end;
//############################################################################//
function TBlockSocket.WaitingData:integer;
var x:integer;
begin
 result:=0;
 if synsock.IoctlSocket(FSocket,FIONREAD,x)=0 then result:=x;
 if result>c64k then result:=c64k;
end;
//############################################################################//
function TBlockSocket.WaitingDataEx:integer;begin if Fbuffer<>'' then result:=length(Fbuffer)else result:=WaitingData;end;
//############################################################################//
procedure TBlockSocket.Purge;
begin
 Sleep(1);
 try
  while (length(Fbuffer)>0) or (WaitingData>0) do begin
   RecvPacket(0);
   if FLastError<>0 then break;
  end;
 except on exception do;end;
 ResetLastError;
end;
//############################################################################//
procedure TBlockSocket.setLinger(Enable:Boolean;Linger:integer);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_Linger;
 d.Enabled:=Enable;
 d.Value:=Linger;
 DelayedOption(d);
end;
//############################################################################//
function TBlockSocket.LocalName:string;
begin
 result:=synsock.GetHostName;
 if result='' then result:='127.0.0.1';
end;
//############################################################################//
procedure TBlockSocket.ResolveNameToIP(Name:string;const IPList:Tstrings);
begin
 IPList.Clear;
 synsock.ResolveNameToIP(Name,FamilyToAF(FFamily),GetSocketprotocol,GetSocketType,IPList);
 if IPList.Count=0 then IPList.Add(cAnyHost);
end;
//############################################################################//
function TBlockSocket.ResolveName(Name:string):string;
var l:TstringList;
begin
 l:=TstringList.Create;
 try
  ResolveNameToIP(Name,l);
  result:=l[0];
 finally l.Free;end;
end;
//############################################################################//
function TBlockSocket.ResolvePort(Port:string):Word;begin result:=synsock.ResolvePort(Port,FamilyToAF(FFamily),GetSocketProtocol,GetSocketType);end;
//############################################################################//
function TBlockSocket.ResolveIPToName(IP:string):string;
begin
 if not IsIP(IP) or not IsIp6(IP) then IP:=ResolveName(IP);
 result:=synsock.ResolveIPToName(IP,FamilyToAF(FFamily),GetSocketProtocol,GetSocketType);
end;
//############################################################################//
procedure TBlockSocket.setRemoteSin(IP,Port:string);begin setSin(FRemoteSin,IP,Port);end;
function TBlockSocket.GetLocalSinIP:string;begin result:=GetSinIP(FLocalSin);end;
function TBlockSocket.GetRemoteSinIP:string;begin result:=GetSinIP(FRemoteSin);end;
function TBlockSocket.GetLocalSinPort:integer;begin result:=GetSinPort(FLocalSin);end;
function TBlockSocket.GetRemoteSinPort:integer;begin result:=GetSinPort(FRemoteSin);end;
//############################################################################//
function TBlockSocket.InternalCanRead(Timeout:integer):Boolean;
var TimeVal:PTimeVal;
TimeV:TTimeVal;
x:integer;
FDset:TFDset;
begin
 TimeV.tv_usec:=(Timeout mod 1000) * 1000;
 TimeV.tv_sec:=Timeout div 1000;
 TimeVal:=@TimeV;
 if Timeout=-1 then TimeVal:=nil;
 FDset:=FFdset;
 x:=synsock.Select(FSocket+1,@FDset,nil,nil,TimeVal);
 SockCheck(x);
 if FLastError<>0 then x:=0;
 result:=x>0;
end;
//############################################################################//
function TBlockSocket.CanRead(Timeout:integer):Boolean;
var ti,tr,n:integer;
begin
 if (FHeartbeatRate<>0) and (Timeout<>-1) then begin
  ti:=Timeout div FHeartbeatRate;
  tr:=Timeout mod FHeartbeatRate;
 end else begin
  ti:=0;
  tr:=Timeout;
 end;
 result:=InternalCanRead(tr);
 if not result then for n:=0 to ti do begin
  DoHeartbeat;
  if FStopFlag then begin
   result:=false;
   FStopFlag:=false;
   Break;
  end;
  result:=InternalCanRead(FHeartbeatRate);
  if result then break;
 end;
 ExceptCheck;
 if result then DoStatus(HR_CanRead,'');
end;
//############################################################################//
function TBlockSocket.CanWrite(Timeout:integer):Boolean;
var TimeVal:PTimeVal;
TimeV:TTimeVal;
x:integer;
FDset:TFDset;
begin
 TimeV.tv_usec:=(Timeout mod 1000)*1000;
 TimeV.tv_sec:=Timeout div 1000;
 TimeVal:=@TimeV;
 if Timeout=-1 then TimeVal:=nil;
 FDset:=FFdset;
 x:=synsock.Select(FSocket+1,nil,@FDset,nil,TimeVal);
 SockCheck(x);
 if FLastError<>0 then x:=0;
 result:=x>0;
 ExceptCheck;
 if result then DoStatus(HR_CanWrite,'');
end;
//############################################################################//
function TBlockSocket.CanReadEx(Timeout:integer):Boolean;begin if Fbuffer<>'' then result:=true else result:=CanRead(Timeout);end;
//############################################################################//
function TBlockSocket.SendbufferTo(buffer:TMemory;length:integer):integer;
begin
 result:=0;
 if TestStopFlag then exit;
 DoMonitor(true,buffer,length);
 LimitBandwidth(length,FMaxSendBandwidth,FNextsend);
 result:=synsock.SendTo(FSocket,buffer,length,MSG_NOSIGNAL,FRemoteSin);
 SockCheck(result);
 ExceptCheck;
 Inc(FSendCounter,result);
 DoStatus(HR_WriteCount,IntToStr(result));
end;
//############################################################################//
function TBlockSocket.RecvbufferFrom(buffer:TMemory;length:integer):integer;
begin
 result:=0;
 if TestStopFlag then exit;
 LimitBandwidth(length,FMaxRecvBandwidth,FNextRecv);
 result:=synsock.RecvFrom(FSocket,buffer,length,MSG_NOSIGNAL,FRemoteSin);
 SockCheck(result);
 ExceptCheck;
 Inc(FRecvCounter,result);
 DoStatus(HR_ReadCount,IntToStr(result));
 DoMonitor(false,buffer,result);
end;
//############################################################################//
function TBlockSocket.GetSizeRecvbuffer:integer;
var l:integer;
begin
 l:=SizeOf(result);
 SockCheck(synsock.GetSockOpt(FSocket,SOL_SOCKET,SO_RCVbuf,@result,l));
 if FLastError<>0 then result:=1024;
 ExceptCheck;
end;
//############################################################################//
procedure TBlockSocket.setSizeRecvbuffer(Size:integer);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_Recvbuff;
 d.Value:=Size;
 DelayedOption(d);
end;
//############################################################################//
function TBlockSocket.GetSizeSendbuffer:integer;
var l:integer;
begin
 l:=SizeOf(result);
 SockCheck(synsock.GetSockOpt(FSocket,SOL_SOCKET,SO_SNDbuf,@result,l));
 if FLastError<>0 then result:=1024;
 ExceptCheck;
end;
//############################################################################//
procedure TBlockSocket.setSizeSendbuffer(Size:integer);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_Sendbuff;
 d.Value:=Size;
 DelayedOption(d);
end;
//############################################################################//
procedure TBlockSocket.setNonBlockMode(Value:Boolean);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_nonblock;
 d.Enabled:=Value;
 DelayedOption(d);
end;
//############################################################################//
procedure TBlockSocket.setTimeout(Timeout:integer);
begin
 setSendTimeout(Timeout);
 setRecvTimeout(Timeout);
end;
//############################################################################//
procedure TBlockSocket.setSendTimeout(Timeout:integer);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_sendtimeout;
 d.Value:=Timeout;
 DelayedOption(d);
end;
//############################################################################//
procedure TBlockSocket.setRecvTimeout(Timeout:integer);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_recvtimeout;
 d.Value:=Timeout;
 DelayedOption(d);
end;
//############################################################################//
function TBlockSocket.GroupCanRead(const SocketList:TList;Timeout:integer;const CanReadList:TList):boolean;
var FDset:TFDset;
TimeVal:PTimeVal;
TimeV:TTimeVal;
x,n,Max:integer;
begin
 TimeV.tv_usec:=(Timeout mod 1000) * 1000;
 TimeV.tv_sec:=Timeout div 1000;
 TimeVal:=@TimeV;
 if Timeout=-1 then TimeVal:=nil;
 FD_ZERO(FDset);
 Max:=0;
 for n:=0 to SocketList.Count-1 do if TObject(SocketList.Items[n]) is TBlockSocket then begin
  if TBlockSocket(SocketList.Items[n]).Socket>Max then Max:=TBlockSocket(SocketList.Items[n]).Socket;
  FD_set(TBlockSocket(SocketList.Items[n]).Socket,FDset);
 end;
 x:=synsock.Select(Max+1,@FDset,nil,nil,TimeVal);
 SockCheck(x);
 ExceptCheck;
 if FLastError<>0 then x:=0;
 result:=x>0;
 CanReadList.Clear;
 if result then for n:=0 to SocketList.Count-1 do if TObject(SocketList.Items[n]) is TBlockSocket then if FD_ISset(TBlockSocket(SocketList.Items[n]).Socket,FDset) then CanReadList.Add(TBlockSocket(SocketList.Items[n]));
end;
//############################################################################//
procedure TBlockSocket.EnableReuse(Value:Boolean);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_reuse;
 d.Enabled:=Value;
 DelayedOption(d);
end;
//############################################################################//
procedure TBlockSocket.setTTL(TTL:integer);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_TTL;
 d.Value:=TTL;
 DelayedOption(d);
end;
//############################################################################//
function TBlockSocket.GetTTL:integer;
var l:integer;
begin
 l:=SizeOf(result);
 if FIP6Used then synsock.GetSockOpt(FSocket,IPPROTO_IPV6,IPV6_UNICAST_HOPS,@result,l)
             else synsock.GetSockOpt(FSocket,IPPROTO_IP,IP_TTL,@result,l);
end;
//############################################################################//
procedure TBlockSocket.setFamily(Value:TSocketFamily);begin FFamily:=Value;FFamilySave:=Value;end;
//############################################################################//
procedure TBlockSocket.setSocket(Value:TSocket);
begin
 FRecvCounter:=0;
 FSendCounter:=0;
 FSocket:=Value;
 FD_ZERO(FFDset);
 FD_set(FSocket,FFDset);
 GetSins;
 FIP6Used:=FRemoteSin.AddressFamily=AF_INET6;
end;
//############################################################################//
function TBlockSocket.GetWsaData:TWSAData;begin result:=WsaDataOnce;end;
function TBlockSocket.GetSocketType:integer;begin result:=0;end;
function TBlockSocket.GetSocketProtocol:integer;begin result:=integer(IPPROTO_IP);end;
procedure TBlockSocket.DoStatus(Reason:THookSocketReason;const Value:string);begin if assigned(OnStatus) then OnStatus(Self,Reason,Value);end;
//############################################################################//
procedure TBlockSocket.DoReadFilter(buffer:TMemory;var len:integer);
var s:string;
begin
 if assigned(OnReadFilter) then if len>0 then begin
  setlength(s,len);
  move(buffer^,Pointer(s)^,len);
  OnReadFilter(Self,s);
  if length(s)>len then setlength(s,len);
  len:=length(s);
  move(Pointer(s)^,buffer^,len);
 end;
end;
//############################################################################//
procedure TBlockSocket.DoCreateSocket;begin if assigned(OnCreateSocket) then OnCreateSocket(Self);end;
procedure TBlockSocket.DoMonitor(Writing:Boolean;const buffer:TMemory;len:integer);begin if assigned(OnMonitor) then OnMonitor(Self,Writing,buffer,len);end;  
procedure TBlockSocket.DoHeartbeat;begin if assigned(OnHeartbeat) and (FHeartbeatRate<>0) then OnHeartbeat(Self);end;
function TBlockSocket.GetErrorDescEx:string;begin result:=GetErrorDesc(FLastError);end;
//############################################################################//
class function TBlockSocket.GetErrorDesc(ErrorCode:integer):string;
begin
 case ErrorCode of
  0:result:='';
  WSAEINTR:result:='Interrupted system call';
  WSAEBADF:result:='Bad file number';
  WSAEACCES:result:='Permission denied';
  WSAEFAULT:result:='Bad address';
  WSAEINVAL:result:='Invalid argument';
  WSAEMFILE:result:='Too many open files';
  WSAEWOULDBLOCK:result:='Operation would block';
  WSAEINPROGRESS:result:='Operation now in progress';
  WSAEALREADY:result:='Operation already in progress';
  WSAENOTSOCK:result:='Socket operation on nonsocket';
  WSAEDESTADDRREQ:result:='Destination address required';
  WSAEMSGSIZE:result:='Message too long';
  WSAEPROTOTYPE:result:='Protocol wrong type for Socket';
  WSAENOPROTOOPT:result:='Protocol not available';
  WSAEPROTONOSUPPORT:result:='Protocol not supported';
  WSAESOCKTNOSUPPORT:result:='Socket not supported';
  WSAEOPNOTSUPP:result:='Operation not supported on Socket';
  WSAEPFNOSUPPORT:result:='Protocol family not supported';
  WSAEAFNOSUPPORT:result:='Address family not supported';
  WSAEADDRINUSE:result:='Address already in use';
  WSAEADDRNOTAVAIL:result:='Can''t assign requested address';
  WSAENETDOWN:result:='Network is down';
  WSAENETUNREACH:result:='Network is unreachable';
  WSAENETREset:result:='Network dropped connection on reset';
  WSAECONNABORTED:result:='Software caused connection abort';
  WSAECONNREset:result:='Connection reset by peer';
  WSAENObufS:result:='No buffer space available';
  WSAEISCONN:result:='Socket is already connected';
  WSAENOTCONN:result:='Socket is not connected';
  WSAESHUTDOWN:result:='Can''t send after Socket shutdown';
  WSAETOOMANYREFS:result:='Too many references:can''t splice';
  WSAETIMEDOUT:result:='Connection timed out';
  WSAECONNREFUSED:result:='Connection refused';
  WSAELOOP:result:='Too many levels of symbolic links';
  WSAENAMETOOLONG:result:='File name is too long';
  WSAEHOSTDOWN:result:='Host is down';
  WSAEHOSTUNREACH:result:='No route to host';
  WSAENOTEMPTY:result:='Directory is not empty';
  WSAEPROCLIM:result:='Too many processes';
  WSAEUSERS:result:='Too many users';
  WSAEDQUOT:result:='Disk quota exceeded';
  WSAESTALE:result:='Stale NFS file handle';
  WSAEREMOTE:result:='Too many levels of remote in path';
  WSASYSNOTREADY:result:='Network subsystem is unusable';
  WSAVERNOTSUPPORTED:result:='Winsock DLL cannot support this application';
  WSANOTINITIALISED:result:='Winsock not initialized';
  WSAEDISCON:result:='Disconnect';
  WSAHOST_NOT_FOUND:result:='Host not found';
  WSATRY_AGAIN:result:='Non authoritative-host not found';
  WSANO_RECOVERY:result:='Non recoverable error';
  WSANO_DATA:result:='Valid name,no data record of requested type'
  else result:='Other Winsock error ('+IntToStr(ErrorCode)+')';
 end;
end;
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
//############################################################################//
constructor TSocksBlockSocket.Create;
begin
 inherited Create;
 FSocksIP:= '';
 FSocksPort:= '1080';
 FSocksTimeout:= 60000;
 FSocksUsername:= '';
 FSocksPassword:= '';
 FUsingSocks:=false;
 FSocksResolver:=true;
 FSocksLastError:=0;
 FSocksResponseIP:='';
 FSocksResponsePort:='';
 FSocksLocalIP:='';
 FSocksLocalPort:='';
 FSocksRemoteIP:='';
 FSocksRemotePort:='';
 FBypassFlag:=false;
 FSocksType:=ST_Socks5;
end;
//############################################################################//
function TSocksBlockSocket.SocksOpen:boolean;
var buf:string;
n:integer;
begin
 result:=false;
 FUsingSocks:=false;
 if FSocksType<>ST_Socks5 then begin
  FUsingSocks:=true;
  result:=true;
 end else begin
  FBypassFlag:=true;
  try
   if FSocksUsername='' then buf:=#5+#1+#0
                        else buf:=#5+#2+#2 +#0;
   Sendstring(buf);
   buf:=RecvbufferStr(2,FSocksTimeout);
   if length(buf)<2 then exit;
   if buf[1]<>#5 then exit;
   n:=Ord(buf[2]);
   case n of
    0:;
    2:begin
     buf:=#1+char(length(FSocksUsername))+FSocksUsername+char(length(FSocksPassword))+FSocksPassword;
     Sendstring(buf);
     buf:=RecvbufferStr(2,FSocksTimeout);
     if length(buf)<2 then exit;
     if buf[2]<>#0 then exit;
    end;
    else exit;
   end;
   FUsingSocks:=true;
   result:=true;
  finally FBypassFlag:=false;end;
 end;
end;
//############################################################################//
function TSocksBlockSocket.SocksRequest(Cmd:Byte;const IP,Port:string):Boolean;
var buf:string;
begin
 FBypassFlag:=true;
 try
  if FSocksType<>ST_Socks5 then buf:=#4+char(Cmd)+SocksCode(IP,Port)
                           else buf:=#5+char(Cmd)+#0+SocksCode(IP,Port);
  Sendstring(buf);
  result:=FLastError=0;
 finally FBypassFlag:=false; end;
end;
//############################################################################//
function TSocksBlockSocket.SocksResponse:Boolean;
var buf,s:string;
x:integer;
begin
 result:=false;
 FBypassFlag:=true;
 try
  FSocksResponseIP:='';
  FSocksResponsePort:='';
  FSocksLastError:=-1;
  if FSocksType<>ST_Socks5 then begin
   buf:=RecvbufferStr(8,FSocksTimeout);
   if FLastError<>0 then exit;
   if buf[1]<>#0 then exit;
   FSocksLastError:=Ord(buf[2]);
  end else begin
   buf:=RecvbufferStr(4,FSocksTimeout);
   if FLastError<>0 then exit;
   if buf[1]<>#5 then exit;
   case Ord(buf[4]) of
    1:s:=RecvbufferStr(4,FSocksTimeout);
    3:begin
     x:=RecvByte(FSocksTimeout);
     if FLastError<>0 then exit;
     s:=char(x)+RecvbufferStr(x,FSocksTimeout);
    end;
    4:s:=RecvbufferStr(16,FSocksTimeout);
    else exit;
   end;
   buf:=buf+s+RecvbufferStr(2,FSocksTimeout);
   if FLastError<>0 then exit;
   FSocksLastError:=Ord(buf[2]);
  end;
  if ((FSocksLastError<>0) and (FSocksLastError<>90)) then exit;
  SocksDecode(buf);
  result:=true;
 finally FBypassFlag:=false;end;
end;
//############################################################################//
function TSocksBlockSocket.SocksCode(IP,Port:string):string;
var ip6:TIp6Bytes;
n:integer;
begin
 if FSocksType<>ST_Socks5 then begin
  result:=CodeInt(ResolvePort(Port));
  if not FSocksResolver then IP:=ResolveName(IP);
  if IsIP(IP) then begin
   result:=result+IPToID(IP);
   result:=result+FSocksUsername+#0;
  end else begin
   result:=result+IPToID('0.0.0.1');
   result:=result+FSocksUsername+#0;
   result:=result+IP+#0;
  end;
 end else begin
  if not FSocksResolver then IP:=ResolveName(IP);
  if IsIP(IP) then result:=#1+IPToID(IP) else if IsIP6(IP) then begin
   ip6:=StrToIP6(IP);
   result:=#4;
   for n:=0 to 15 do result:=result+char(ip6[n]);
  end else result:=#3+char(length(IP))+IP;
  result:=result+CodeInt(ResolvePort(Port));
 end;
end;
//############################################################################//
function TSocksBlockSocket.SocksDecode(Value:string):integer;
var Atyp:Byte;
y,n:integer;
w:Word;
ip6:TIp6Bytes;
begin
 FSocksResponsePort:='0';
 result:=0;
 if FSocksType<>ST_Socks5 then begin
  if length(Value)<8 then exit;
  result:=3;
  w:=DecodeInt(Value,result);
  FSocksResponsePort:=IntToStr(w);
  FSocksResponseIP:=Format('%d.%d.%d.%d',
   [Ord(Value[5]),Ord(Value[6]),Ord(Value[7]),Ord(Value[8])]);
  result:=9;
 end else begin
  if length(Value)<4 then exit;
  Atyp:=Ord(Value[4]);
  result:=5;
  case Atyp of
   1:begin
    if length(Value)<10 then exit;
    FSocksResponseIP:=Format('%d.%d.%d.%d',[Ord(Value[5]),Ord(Value[6]),Ord(Value[7]),Ord(Value[8])]);
    result:=9;
   end;
   3:begin
    y:=Ord(Value[5]);
    if length(Value)<(5+y+2) then exit;
    for n:=6 to 6+y-1 do FSocksResponseIP:=FSocksResponseIP+Value[n];
    result:=5+y+1;
   end;
   4:begin
    if length(Value)<22 then exit;
    for n:=0 to 15 do ip6[n]:=ord(Value[n+5]);
    FSocksResponseIP:=IP6ToStr(ip6);
    result:=21;
   end;
   else exit;
  end;
  w:=DecodeInt(Value,result);
  FSocksResponsePort:=IntToStr(w);
  result:=result+2;
 end;
end;
//############################################################################//
//############################################################################//
//############################################################################//
procedure TDgramBlockSocket.Connect(IP,Port:string);
begin
 setRemoteSin(IP,Port);
 InternalCreateSocket(FRemoteSin);
 Fbuffer:='';
 DoStatus(HR_Connect,IP+':'+Port);
end;
//############################################################################//
function TDgramBlockSocket.Recvbuffer(buffer:TMemory;length:integer):integer;
begin
 result:=RecvbufferFrom(buffer,length);
end;
//############################################################################//
function TDgramBlockSocket.Sendbuffer(buffer:TMemory;length:integer):integer;
begin
 result:=SendbufferTo(buffer,length);
end;
//############################################################################//
//############################################################################//
//############################################################################//
destructor TUDPBlockSocket.Destroy;
begin
 if Assigned(FSocksControlSock) then FSocksControlSock.Free;
 inherited;
end;
//############################################################################//
procedure TUDPBlockSocket.EnableBroadcast(Value:Boolean);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_Broadcast;
 d.Enabled:=Value;
 DelayedOption(d);
end;
//############################################################################//
function TUDPBlockSocket.UdpAssociation:Boolean;
var b:Boolean;
begin
 result:=true;
 FUsingSocks:=false;
 if FSocksIP<>'' then begin
  result:=false;
  if not Assigned(FSocksControlSock) then FSocksControlSock:=TTCPBlockSocket.Create;
  FSocksControlSock.CloseSocket;
  FSocksControlSock.CreateSocketByName(FSocksIP);
  FSocksControlSock.Connect(FSocksIP,FSocksPort);
  if FSocksControlSock.LastError<>0 then exit;
  // if not assigned local port,assign it!
  if not FBinded then Bind(cAnyHost,cAnyPort);
  //open control TCP connection to SOCKS
  FSocksControlSock.FSocksUsername:=FSocksUsername;
  FSocksControlSock.FSocksPassword:=FSocksPassword;
  b:=FSocksControlSock.SocksOpen;
  if b then b:=FSocksControlSock.SocksRequest(3,GetLocalSinIP,IntToStr(GetLocalSinPort));
  if b then b:=FSocksControlSock.SocksResponse;
  if not b and (FLastError=0) then FLastError:=WSANO_RECOVERY;
  FUsingSocks :=FSocksControlSock.UsingSocks;
  FSocksRemoteIP:=FSocksControlSock.FSocksResponseIP;
  FSocksRemotePort:=FSocksControlSock.FSocksResponsePort;
  result:=b and (FLastError=0);
 end;
end;
//############################################################################//
function TUDPBlockSocket.SendbufferTo(buffer:TMemory;length:integer):integer;
var SIp,buf:string;
SPort:integer;
begin
 result:=0;
 FUsingSocks:=false;
 if (FSocksIP<>'') and (not UdpAssociation) then FLastError:=WSANO_RECOVERY else begin
  if FUsingSocks then begin
   Sip:=GetRemoteSinIp;
   SPort:=GetRemoteSinPort;
   setRemoteSin(FSocksRemoteIP,FSocksRemotePort);
   setlength(buf,length);
   move(buffer^,PChar(buf)^,length);
   buf:=#0+#0+#0+SocksCode(Sip,IntToStr(SPort))+buf;
   result:=inherited SendbufferTo(PChar(buf),System.length(buf));
   setRemoteSin(Sip,IntToStr(SPort));
  end else result:=inherited SendbufferTo(buffer,length);
 end;
end;
//############################################################################//
function TUDPBlockSocket.RecvbufferFrom(buffer:TMemory;length:integer):integer;
var buf:string;
x:integer;
begin
 result:=inherited RecvbufferFrom(buffer,length);
 if FUsingSocks then begin
  setlength(buf,result);
  move(buffer^,PChar(buf)^,result);
  x:=SocksDecode(buf);
  result:=result-x+1;
  buf:=Copy(buf,x,result);
  move(PChar(buf)^,buffer^,result);
  setRemoteSin(FSocksResponseIP,FSocksResponsePort);
 end;
end;
//############################################################################//
procedure TUDPBlockSocket.AddMulticast(MCastIP:string);
var Multicast:TIP_mreq;
Multicast6:TIPv6_mreq;
n:integer;
ip6:Tip6bytes;
begin
 if FIP6Used then begin
  ip6:=StrToIp6(MCastIP);
  for n:=0 to 15 do Multicast6.ipv6mr_multiaddr.u6_addr8[n]:=Ip6[n];
  Multicast6.ipv6mr_interface:=0;
  SockCheck(synsock.setSockOpt(FSocket,IPPROTO_IPV6,IPV6_JOIN_GROUP, pchar(@Multicast6),SizeOf(Multicast6)));
 end else begin
  Multicast.imr_multiaddr.S_addr:=swapbytes(strtoip(MCastIP));
  Multicast.imr_interface.S_addr:=INADDR_ANY;
  SockCheck(synsock.setSockOpt(FSocket,IPPROTO_IP,IP_ADD_MEMBERSHIP, pchar(@Multicast),SizeOf(Multicast)));
 end;
 ExceptCheck;
end;
//############################################################################//
procedure TUDPBlockSocket.DropMulticast(MCastIP:string);
var Multicast:TIP_mreq;
Multicast6:TIPv6_mreq;
n:integer;
ip6:Tip6bytes;
begin
 if FIP6Used then begin
  ip6:=StrToIp6(MCastIP);
  for n:=0 to 15 do Multicast6.ipv6mr_multiaddr.u6_addr8[n]:=Ip6[n];
  Multicast6.ipv6mr_interface:=0;
  SockCheck(synsock.setSockOpt(FSocket,IPPROTO_IPV6,IPV6_LEAVE_GROUP, pchar(@Multicast6),SizeOf(Multicast6)));
 end else begin
  Multicast.imr_multiaddr.S_addr:=swapbytes(strtoip(MCastIP));
  Multicast.imr_interface.S_addr:=INADDR_ANY;
  SockCheck(synsock.setSockOpt(FSocket,IPPROTO_IP,IP_DROP_MEMBERSHIP, pchar(@Multicast),SizeOf(Multicast)));
 end;
 ExceptCheck;
end;
//############################################################################//
procedure TUDPBlockSocket.setMulticastTTL(TTL:integer);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_MulticastTTL;
 d.Value:=TTL;
 DelayedOption(d);
end;
//############################################################################//
function TUDPBlockSocket.GetMulticastTTL:integer;
var l:integer;
begin
 l:=SizeOf(result);
 if FIP6Used then synsock.GetSockOpt(FSocket,IPPROTO_IPV6,IPV6_MULTICAST_HOPS,@result,l)
             else synsock.GetSockOpt(FSocket,IPPROTO_IP,IP_MULTICAST_TTL,@result,l);
end;
//############################################################################//
procedure TUDPBlockSocket.EnableMulticastLoop(Value:Boolean);
var d:TSynaOption;
begin
 d:=TSynaOption.Create;
 d.Option:=SOT_MulticastLoop;
 d.Enabled:=Value;
 DelayedOption(d);
end;
//############################################################################//
function TUDPBlockSocket.GetSocketType:integer;begin result:=integer(SOCK_DGRAM);end;
function TUDPBlockSocket.GetSocketProtocol:integer;begin result:=integer(IPPROTO_UDP);end;
//############################################################################//
//############################################################################//
//############################################################################//
constructor TTCPBlockSocket.Create;
begin
 inherited Create;
 FHTTPTunnelIP:='';
 FHTTPTunnelPort:='';
 FHTTPTunnel:=false;
 FHTTPTunnelRemoteIP:='';
 FHTTPTunnelRemotePort:='';
 FHTTPTunnelUser:='';
 FHTTPTunnelPass:='';
 FHTTPTunnelTimeout:=30000;
end;
//############################################################################//
destructor TTCPBlockSocket.Destroy;begin inherited Destroy;end;
function TTCPBlockSocket.GetErrorDescEx:string;begin result:=inherited GetErrorDescEx;end;
//############################################################################//
procedure TTCPBlockSocket.CloseSocket;
begin
 if (FSocket<>INVALID_SOCKET) and (FLastError=0) then begin
  Synsock.Shutdown(FSocket,1);
  Purge;
 end;
 inherited CloseSocket;
end;
//############################################################################//
procedure TTCPBlockSocket.DoAfterConnect;begin if assigned(OnAfterConnect) then OnAfterConnect(Self);end;
function TTCPBlockSocket.WaitingData:integer;begin result:=inherited WaitingData;end;
//############################################################################//
procedure TTCPBlockSocket.Listen;
var b:Boolean;
Sip,SPort:string;
begin
 if FSocksIP='' then begin
  SockCheck(synsock.Listen(FSocket,SOMAXCONN));
  GetSins;
 end else begin
  Sip:=GetLocalSinIP;
  if Sip=cAnyHost then Sip:=LocalName;
  SPort:=IntToStr(GetLocalSinPort);
  inherited Connect(FSocksIP,FSocksPort);
  b:=SocksOpen;
  if b then b:=SocksRequest(2,Sip,SPort);
  if b then b:=SocksResponse;
  if not b and (FLastError=0) then FLastError:=WSANO_RECOVERY;
  FSocksLocalIP:=FSocksResponseIP;
  if FSocksLocalIP=cAnyHost then FSocksLocalIP:=FSocksIP;
  FSocksLocalPort:=FSocksResponsePort;
  FSocksRemoteIP:='';
  FSocksRemotePort:='';
 end;
 ExceptCheck;
 DoStatus(HR_Listen,'');
end;
//############################################################################//
function TTCPBlockSocket.Accept:TSocket;
begin
 if FUsingSocks then begin
  if not SocksResponse and (FLastError=0) then FLastError:=WSANO_RECOVERY;
  FSocksRemoteIP:=FSocksResponseIP;
  FSocksRemotePort:=FSocksResponsePort;
  result:=FSocket;
 end else result:=synsock.Accept(FSocket,FRemoteSin);
 ExceptCheck;
 DoStatus(HR_Accept,'');
end;
//############################################################################//
procedure TTCPBlockSocket.Connect(IP,Port:string);
begin
 if FSocksIP<>'' then SocksDoConnect(IP,Port)
 else if FHTTPTunnelIP<>'' then HTTPTunnelDoConnect(IP,Port) 
 else inherited Connect(IP,Port);
 if FLasterror=0 then DoAfterConnect;
end;
//############################################################################//
procedure TTCPBlockSocket.SocksDoConnect(IP,Port:string);
var b:Boolean;
begin
 inherited Connect(FSocksIP,FSocksPort);
 if FLastError=0 then begin
  b:=SocksOpen;
  if b then b:=SocksRequest(1,IP,Port);
  if b then b:=SocksResponse;
  if not b and (FLastError=0) then FLastError:=WSASYSNOTREADY;
  FSocksLocalIP:=FSocksResponseIP;
  FSocksLocalPort:=FSocksResponsePort;
  FSocksRemoteIP:=IP;
  FSocksRemotePort:=Port;
 end;
 ExceptCheck;
 DoStatus(HR_Connect,IP+':'+Port);
end;
//############################################################################//
procedure TTCPBlockSocket.HTTPTunnelDoConnect(IP,Port:string);
var s:string;
begin
 Port:=IntToStr(ResolvePort(Port));
 inherited Connect(FHTTPTunnelIP,FHTTPTunnelPort);
 if FLastError<>0 then exit;
 FHTTPTunnel:=false;
 if IsIP6(IP) then IP:='['+IP+']';
 Sendstring('CONNECT '+IP+':'+Port+' HTTP/1.0'+CRLF);
 if FHTTPTunnelUser<>'' then Sendstring('Proxy-Authorization:Basic ' + EncodeBase64(FHTTPTunnelUser+':'+FHTTPTunnelPass)+CRLF);
 Sendstring(CRLF);
 repeat
  s:=RecvTerminated(FHTTPTunnelTimeout,#$0a);
  if FLastError<>0 then Break;
  if (Pos('HTTP/',s)=1) and (length(s)>11) then FHTTPTunnel:=s[10]='2';
 until (s='') or (s=#$0d);
 if (FLasterror=0) and not FHTTPTunnel then FLastError:=WSASYSNOTREADY;
 FHTTPTunnelRemoteIP:=IP;
 FHTTPTunnelRemotePort:=Port;
 ExceptCheck;
end;
//############################################################################//
procedure TTCPBlockSocket.SSLDoConnect;begin ResetLastError;ExceptCheck;end;
procedure TTCPBlockSocket.SSLDoShutdown;begin ResetLastError;end;
//############################################################################//
function TTCPBlockSocket.GetLocalSinIP:string;
begin
 if FUsingSocks then result:=FSocksLocalIP
                else result:=inherited GetLocalSinIP;
end;
//############################################################################//
function TTCPBlockSocket.GetRemoteSinIP:string;
begin
 if FUsingSocks then result:=FSocksRemoteIP
 else if FHTTPTunnel then result:=FHTTPTunnelRemoteIP
 else result:=inherited GetRemoteSinIP;
end;
//############################################################################//
function TTCPBlockSocket.GetLocalSinPort:integer;
begin
 if FUsingSocks then result:=StrToIntDef(FSocksLocalPort,0)
                else result:=inherited GetLocalSinPort;
end;
//############################################################################//
function TTCPBlockSocket.GetRemoteSinPort:integer;
begin
 if FUsingSocks then result:=ResolvePort(FSocksRemotePort)
 else if FHTTPTunnel then result:=StrToIntDef(FHTTPTunnelRemotePort,0)
 else result:=inherited GetRemoteSinPort;
end;      
//############################################################################//
function TTCPBlockSocket.SSLAcceptConnection:Boolean;
begin
 ResetLastError;
 ExceptCheck;
 result:=FLastError=0;
end;
//############################################################################//
function TTCPBlockSocket.Recvbuffer(buffer:TMemory;len:integer):integer;begin result:=inherited Recvbuffer(buffer,len);end;
function TTCPBlockSocket.Sendbuffer(buffer:TMemory;length:integer):integer;begin result:=inherited Sendbuffer(buffer,length);end;
function TTCPBlockSocket.GetSocketType:integer;begin result:=integer(SOCK_STREAM);end;
function TTCPBlockSocket.GetSocketProtocol:integer;begin result:=integer(IPPROTO_TCP);end;
//############################################################################//
function TICMPBlockSocket.GetSocketType:integer;begin result:=integer(SOCK_RAW);end;
function TICMPBlockSocket.GetSocketProtocol:integer;begin if FIP6Used then result:=integer(IPPROTO_ICMPV6)else result:=integer(IPPROTO_ICMP);end;        
//############################################################################//
function TRAWBlockSocket.GetSocketType:integer;begin result:=integer(SOCK_RAW);end;
function TRAWBlockSocket.GetSocketProtocol:integer;begin result:=integer(IPPROTO_RAW);end;
//############################################################################//
constructor TSynaClient.Create;
begin
 inherited Create;
 FIPInterface:=cAnyHost;
 FTargetHost:=cLocalhost;
 FTargetPort:=cAnyPort;
 FTimeout:=5000;
 FUsername:='';
 FPassword:='';
end;
//############################################################################//
//############################################################################//
//############################################################################//
{$IFDEF ONCEWINSOCK}
initialization
begin
 if not InitSocketInterface(DLLStackName) then begin
  e:=ESynapseError.Create('Error loading Socket interface ('+DLLStackName+')!');
  e.ErrorCode:=0;
  e.ErrorMessage:='Error loading Socket interface ('+DLLStackName+')!';
  raise e;
 end;
 synsock.WSAStartup(WinsockLevel,WsaDataOnce);
end;
{$ENDIF}
//############################################################################//
finalization
begin
{$IFDEF ONCEWINSOCK}
 synsock.WSACleanup;
 DestroySocketInterface;
{$ENDIF}
end;
//############################################################################//
end. 
//############################################################################//
