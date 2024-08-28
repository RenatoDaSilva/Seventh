unit uVideo;

interface

uses
  System.Classes, System.JSON, System.SysUtils, System.Generics.Collections,
  IdHTTP, uComposites, uPersist;

type
  TVideo = class
  private
    function VideoDataToJSON(aVideoData: TVideoData): string; overload;
    function VideoDataToJSON(aVideoData: TList<TVideoData>): string; overload;
  public
    function Add(aVideoData: TvideoData): TResponse;
    function Retrieve(aServerID, aVideoID: string): TResponse;
    function Delete(aServerID, aVideoID: string): TResponse;
    function RetrieveList(aServerID: string): TResponse;
    function ParamsToVideoData(const Params: TStrings): TVideoData;
  end;

implementation

function TVideo.Add(aVideoData: TVideoData): TResponse;
var
  Persist: TPersist;
begin
  Persist := TPersist.Create(nil);
  try
    Result.JSON := VideoDataToJSON(Persist.AddVideo(aVideoData));
    Result.Status := 200;
  finally
    Persist.Free;
  end;
end;

function TVideo.Delete(aServerID, aVideoID: string): TResponse;
var
  Persist: TPersist;
begin
  Persist := TPersist.Create(nil);
  try
    Result.JSON := '{response: Video não encontrado}';
    Result.Status := 0;

    if Persist.DeleteVideo(aServerID, aVideoID) then
    begin
      Result.JSON := Format('{response: Video com o ID %s excluído com sucesso}', [aVideoID]);
      Result.Status := 200;
    end;
  finally
    Persist.Free;
  end;
end;

function TVideo.Retrieve(aServerID, aVideoID: string): TResponse;
var
  Persist: TPersist;
begin
  Persist := TPersist.Create(nil);
  try
    Result.JSON := VideoDataToJSON(Persist.RetrieveVideo(aServerID, aVideoID));
    Result.Status := 200;
  finally
    Persist.Free;
  end;
end;

function TVideo.RetrieveList(aServerID: string): TResponse;
var
  Persist: TPersist;
  VideoDataList: TList<TVideoData>;
begin
  Persist := TPersist.Create(nil);
  try
    VideoDataList := Persist.RetrieveVideoList(aServerID);
    try
      Result.JSON := VIdeoDataToJSON(VideoDataList);
      Result.Status := 200;
    finally
      VideoDataList.Free;
    end;
  finally
    Persist.Free;
  end;
end;

function TVideo.VideoDataToJSON(aVideoData: TVideoData): string;
var
  JSONObject: TJSONObject;
begin
  JSONObject := TJSONObject.Create;
  try
    JSONObject.AddPair('id', aVideoData.ID);
    if aVideoData.ServerID <> '' then
      JSONObject.AddPair('serverId', aVideoData.ServerID);
    JSONObject.AddPair('description', aVideoData.Description);
    if aVideoData.VideoContent <> '' then
      JSONObject.AddPair('videoContent', aVideoData.VideoContent);
    JSONObject.AddPair('sizeInBytes', aVideoData.SizeInBytes);

    Result := JSONObject.ToJSON;
  finally
    JSONObject.Free;
  end;
end;

function TVideo.VideoDataToJSON(aVideoData: TList<TVideoData>): string;
var
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  VideoData: TVideoData;
begin
  JSONArray := TJSONArray.Create;

  try
    for VideoData in aVideoData do
    begin
      JSONObject := TJSONObject.Create;
      try
        JSONObject.AddPair('id', VideoData.ID);
        JSONObject.AddPair('description', VideoData.Description);
        JSONObject.AddPair('sizeInBytes', VideoData.SizeInBytes);
      finally
        JSONArray.AddElement(JSONObject);
      end;
    end;

    Result := JSONArray.ToJSON;
  finally
    JSONArray.Free;
  end;
end;

function TVideo.ParamsToVideoData(const Params: TStrings): TVideoData;
begin
  Result.ID := Params.Values['id'];
  Result.ServerID := Params.Values['serverId'];
  Result.Description := Params.Values['description'];
  Result.VideoContent := Params.Values['videoContent'];
  Result.SizeInBytes := StrToIntDef(Params.Values['sizeInBytes'], 0);
end;


end.
