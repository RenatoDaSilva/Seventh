unit uAPI;

interface

uses
  System.Classes, System.SysUtils, uServer, uComposites, IdCustomHTTPServer,
  uRecycler;

type
  TAPI = class
  private
    FURIList: TStrings;
    FResponse: TResponse;
    FServer: TServer;
    FRecycler: TRecycler;
  private
    function ProcessRecycler(aDays: integer): TResponse;
    function CheckRecyclerStatus: TResponse;
  public
    constructor Create;
    destructor Destroy; override;
    property Response: TResponse read FResponse write FResponse;

    procedure Process(aIdHTTPRequestInfo: TIdHTTPRequestInfo);
  end;

implementation

constructor TAPI.Create;
begin
  FURIList := TStringList.Create;
  FServer := TServer.Create;
end;

destructor TAPI.Destroy;
begin
  FURIList.Free;
  FServer.Free;
end;

procedure TAPI.Process(aIdHTTPRequestInfo: TIdHTTPRequestInfo);
var
  Action: string;
  ServerId, VideoId: string;
  VideoData: TVideoData;
begin
  FURIList.Delimiter := '/';
  FURIList.DelimitedText := aIdHTTPRequestInfo.Document;

  Action := FURIList[2];

  case aIdHTTPRequestInfo.CommandType of
    hcGET:
      begin
        if Action = 'servers' then
        begin
          if FURIList.Count < 4 then
            Response := FServer.RetrieveList
          else
            if FURIList[3] = 'available' then
              Response := FServer.CheckIfIPAndPortAreAvailable(FURIList[4])
          else
            if FURIList[4] = 'videos' then
            begin
              ServerId := FURIList[3];
              if FURIList.Count < 6 then
                Response := FServer.Video.RetrieveList(ServerId)
              else
              begin
                VideoId := FURIList[5];
                Response := FServer.Video.Retrieve(ServerId, VideoId);
              end;
            end
            else
              Response := FServer.Retrieve(FURIList[3]);
        end;

        if Action = 'recycler' then
        begin
          if FURIList[3] = 'process' then
            Response := ProcessRecycler(StrToIntDef(FURIList[4], MaxInt));
          if FURIList[3] = 'status' then
            Response := CheckRecyclerStatus;
        end;
      end;

    hcPOST:
      begin
        if Action = 'server' then
          Response := FServer.Add(FServer.ParamsToServerData(aIdHTTPRequestInfo.Params));

        if Action = 'servers' then
        begin
          ServerId := FURIList[3];
          if FURIList[4] = 'videos' then
          begin
            VideoData := FServer.Video.ParamsToVideoData(aIdHTTPRequestInfo.Params);
            VideoData.ServerID := ServerId;
            Response := FServer.Video.Add(VideoData);
          end;
        end;
      end;

    hcDELETE:
      begin
        if Action = 'servers' then
        begin
          ServerId := FURIList[3];
          if FURIList[4] = 'videos' then
          begin
            VideoId := FURIList[5];
            Response := FServer.Video.Delete(ServerId, VideoId);
          end
          else
            Response := FServer.Delete(ServerId);
        end;
      end;
  end;
end;

function TAPI.ProcessRecycler(aDays: integer): TResponse;
begin
  FRecycler := TRecycler.Create;
  FRecycler.FreeOnTerminate := True;
  FRecycler.Start;
  Result.JSON :='{ "status": "running" }';
  Result.Status := 202;
end;

function TAPI.CheckRecyclerStatus: TResponse;
begin
  Result.Status := 200;

  if FRecycler = nil then
    Result.JSON :='{ "status": "not running" }'
  else
    Result.JSON :='{ "status": "running" }';
end;

end.

