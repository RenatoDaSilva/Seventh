unit uServer;

interface

uses
  System.Classes, System.JSON, System.SysUtils, System.Generics.Collections,
  IdHTTP, uComposites, uPersist, uVideo;

type
  TServer = class
  private
    FResponse: TResponse;
    FVideo: TVideo;

    function ServerDataToJSON(aServerData: TServerData): string; overload;
    function ServerDataToJSON(aServerData: TList<TServerData>): string; overload;
    function GetVideo: TVideo;
    procedure SetVideo(const Value: TVideo);
  public
    constructor Create;
    destructor Destroy; override;
    property Response: TResponse read FResponse write FResponse;
    property Video: TVideo read GetVideo write SetVideo;

    function ParamsToServerData(const Params: TStrings): TServerData;
    function Add(aServerData:TServerData): TResponse;
    function Delete(aServerID: string): TResponse;
    function Retrieve(aServerID: string): TResponse;
    function RetrieveList: TResponse;
    function CheckIfIPAndPortAreAvailable(aServerID: string): TResponse;
  end;

implementation

constructor TServer.Create;
begin
  FVideo := TVideo.Create;
end;

destructor TServer.Destroy;
begin
  FVideo.Free;
end;

function TServer.GetVideo: TVideo;
begin
  Result := FVideo;
end;

function TServer.Add(aServerData:TServerData): TResponse;
var
  Persist: TPersist;
begin
  Persist := TPersist.Create(nil);
  try
    Result.JSON := ServerDataToJSON(Persist.CreateServer(aServerData));
    Result.Status := 200;
  finally
    Persist.Free;
  end;
end;

function TServer.Retrieve(aServerID: string): TResponse;
var
  Persist: TPersist;
begin
  Persist := TPersist.Create(nil);
  try
    Result.JSON := ServerDataToJSON(Persist.RetrieveServer(aServerID));
    Result.Status := 200;
  finally
    Persist.Free;
  end;
end;

function TServer.RetrieveList: TResponse;
var
  Persist: TPersist;
  ServerDataList: TList<TServerData>;
begin
  Persist := TPersist.Create(nil);
  try
    ServerDataList := Persist.RetrieveServerList;
    try
      Result.JSON := ServerDataToJSON(ServerDataList);
      Result.Status := 200;
    finally
      ServerDataList.Free;
    end;
  finally
    Persist.Free;
  end;
end;

function TServer.ServerDataToJSON(aServerData: TServerData): string;
var
  JSONObject: TJSONObject;
begin
  JSONObject := TJSONObject.Create;
  try
    JSONObject.AddPair('id', aServerData.ID);
    JSONObject.AddPair('name', aServerData.Name);
    JSONObject.AddPair('ip', aServerData.IP);
    JSONObject.AddPair('port', aServerData.Port);

    Result := JSONObject.ToJSON;
  finally
    JSONObject.Free;
  end;
end;

function TServer.ServerDataToJSON(aServerData: TList<TServerData>): string;
var
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  ServerData: TServerData;
begin
  JSONArray := TJSONArray.Create;

  try
    for ServerData in aServerData do
    begin
      JSONObject := TJSONObject.Create;
      try
        JSONObject.AddPair('id', ServerData.ID);
        JSONObject.AddPair('name', ServerData.Name);
        JSONObject.AddPair('ip', ServerData.IP);
        JSONObject.AddPair('port', ServerData.Port);
      finally
        JSONArray.AddElement(JSONObject);
      end;
    end;

    Result := JSONArray.ToJSON;
  finally
    JSONArray.Free;
  end;
end;

procedure TServer.SetVideo(const Value: TVideo);
begin
  FVideo := Value;
end;

function TServer.ParamsToServerData(const Params: TStrings): TServerData;
begin
  Result.ID := Params.Values['id'];
  Result.Name := Params.Values['name'];
  Result.IP := Params.Values['ip'];
  Result.Port := StrToIntDef(Params.Values['port'], 0);
end;

function TServer.Delete(aServerID: string): TResponse;
var
  Persist: TPersist;
begin
  Persist := TPersist.Create(nil);
  try
    Result.JSON := Format('{response: Não foi encontrado registro com o ID %s}', [aServerID]);
    Result.Status := 0;

    if Persist.DeleteServer(aServerID) then
    begin
      Result.JSON := Format('{response: Registro com o ID %s excluído com sucesso}', [aServerID]);
      Result.Status := 200;
    end;
  finally
    Persist.Free;
  end;
end;

function TServer.CheckIfIPAndPortAreAvailable(aServerID: string): TResponse;
var
  Persist: TPersist;
  HTTP: TIdHTTP;
  ServerData: TServerData;
  URL: string;
begin
  Persist := TPersist.Create(nil);
  try
    ServerData := Persist.RetrieveServer(aServerID);
    URL := Format('http://%s:%d', [ServerData.IP, ServerData.Port]);
  finally
    Persist.Free;
  end;

  HTTP := TIdHTTP.Create(nil);
  try
    Result.Status := 200;
    try
      HTTP.Head(URL);
      Result.JSON := '{available: true}';
    except
      Result.JSON := '{available: false}';
    end;
  finally
    HTTP.Free;
  end;
end;

end.
