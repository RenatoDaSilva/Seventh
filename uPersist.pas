unit uPersist;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Forms, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  uComposites, System.Generics.Collections;

type
  TPersist = class(TDataModule)
    conPersist: TFDConnection;
    qryPersist: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private const
      DB_FILE_NAME = 'db_7th.sqlite';
  private
    FDBFullPath: string;

    procedure CreateDBFile;
    procedure ConnectToDBFile;
    procedure ExecSQL(aSQL: string);
    function GenerateGUID: string;
    procedure DisconnectFromDBFile;

  public
    function CreateServer(aServerData: TserverData): TServerData;
    function DeleteServer(aServerID: String): boolean;
    function RetrieveServer(aServerID: String): TServerData;
    function RetrieveServerList: TList<TServerData>;

    function AddVideo(aVideoData: TVideoData): TVideoData;
    function DeleteVideo(aServerID, aVideoID: String): boolean;
    function RetrieveVideo(aServerID, aVideoID: String): TVideoData;
    function RetrieveVideoList(aServerID: string): TList<TVideoData>;

    procedure RecycleVideos(aDays: integer);
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TPersist.DataModuleCreate(Sender: TObject);
begin
  FDBFullPath := ExtractFilePath(Application.ExeName) + DB_FILE_NAME;

  if not FileExists(FDBFullPath) then
    CreateDBFile;
end;

procedure TPersist.CreateDBFile;
begin
  ConnectToDBFile;

  try
    ExecSQL('CREATE TABLE "server" (' +
            ' "id" TEXT NOT NULL,' +
            ' "name" TEXT NOT NULL,' +
            ' "ip" TEXT NOT NULL,' +
            ' "port" INTEGER NOT NULL,' +
            ' PRIMARY KEY("id")' +
            ');');


    ExecSQL('CREATE TABLE "video" (' +
            ' "id" TEXT NOT NULL UNIQUE,' +
            ' "serverid" TEXT NOT NULL,' +
            ' "description" TEXT NOT NULL,' +
            ' "videocontent" BLOB,' +
            ' "sizeinbytes" INTEGER,' +
            ' "incdate" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,' +
            ' PRIMARY KEY("id")' +
            ' FOREIGN KEY ("serverid") REFERENCES server("id")' +
            ');');
  finally
    DisconnectFromDBFile;
  end;
end;

function TPersist.AddVideo(aVideoData: TVideoData): TVideoData;
var
  NewGUID: string;
begin
  ConnectToDBFile;
  try
    NewGUID := GenerateGUID;

    qryPersist.SQL.Text := 'INSERT INTO video(id, serverid, description, ' +
                           'videocontent, sizeinbytes) VALUES (:id, :serverid, ' +
                           ':description, :videocontent, :sizeinbytes);';
    qryPersist.ParamByName('id').AsString := NewGUID;
    qryPersist.ParamByName('serverid').AsString := aVideoData.ServerID;
    qryPersist.ParamByName('description').AsString := aVideoData.Description;
    qryPersist.ParamByName('videocontent').AsString := aVideoData.VideoContent;
    qryPersist.ParamByName('sizeinbytes').AsInteger := aVideoData.SizeInBytes;

    qryPersist.ExecSQL;

    Result := aVideoData;
    Result.ID := NewGUID;

  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

procedure TPersist.ConnectToDBFile;
begin
  conPersist.Params.Database := FDBFullPath;
  conPersist.Params.Add('LockingMode=Normal');
  conPersist.Params.Add('Synchronous=Full');
  conPersist.LoginPrompt := False;

  conPersist.Connected := True;
end;

procedure TPersist.DisconnectFromDBFile;
begin
  conPersist.Connected := False;
end;

procedure TPersist.ExecSQL(aSQL: string);
begin
  if conPersist.Connected then
  begin
    qryPersist.SQL.Text := aSQL;
    qryPersist.ExecSQL;
  end;
end;

function TPersist.GenerateGUID: string;
var
  GUID: TGUID;
begin
  Result := '';

  if CreateGUID(GUID) = S_OK then
    result := GUIDToString(GUID);
end;

function TPersist.RetrieveServer(aServerID: String): TServerData;
begin
  ConnectToDBFile;
  try
    qryPersist.SQL.Text := 'SELECT id, name, ip, port FROM server WHERE id = :id;';
    qryPersist.ParamByName('id').AsString := aServerID;

    qryPersist.Open;

    Result.ID := qryPersist.FieldByName('id').AsString;
    Result.Name := qryPersist.FieldByName('name').AsString;
    Result.IP := qryPersist.FieldByName('ip').AsString;
    Result.Port := qryPersist.FieldByName('port').AsInteger;
  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

function TPersist.RetrieveVideo(aServerID, aVideoID: String): TVideoData;
begin
  ConnectToDBFile;
  try
    qryPersist.SQL.Text := 'SELECT id, description, sizeinbytes ' +
      'FROM video WHERE id = :videoid and serverid = :serverid;';
    qryPersist.ParamByName('videoid').AsString := aVideoID;
    qryPersist.ParamByName('serverid').AsString := aServerID;

    qryPersist.Open;

    Result.ID := qryPersist.FieldByName('id').AsString;
    Result.Description := qryPersist.FieldByName('description').AsString;
    Result.SizeInBytes := qryPersist.FieldByName('sizeinbytes').AsInteger;
  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

function TPersist.RetrieveServerList: TList<TServerData>;
var
  ServerData: TServerData;
begin
  ConnectToDBFile;
  Result := TList<TServerData>.Create;
  try
    qryPersist.SQL.Text := 'SELECT id, name, ip, port FROM server;';

    qryPersist.Open;

    while not qryPersist.Eof do
    begin
      ServerData.ID := qryPersist.FieldByName('id').AsString;
      ServerData.Name := qryPersist.FieldByName('name').AsString;
      ServerData.IP := qryPersist.FieldByName('ip').AsString;
      ServerData.Port := qryPersist.FieldByName('port').AsInteger;

      Result.Add(ServerData);

      qryPersist.Next;
    end;
  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

function TPersist.RetrieveVideoList(aServerID: string): TList<TVideoData>;
var
  VideoData: TVideoData;
begin
  ConnectToDBFile;
  Result := TList<TVideoData>.Create;
  try
    qryPersist.SQL.Text := 'SELECT id, description, sizeinbytes ' +
      'FROM video WHERE serverid = :serverid;';
    qryPersist.ParamByName('serverid').AsString := aServerID;

    qryPersist.Open;

    while not qryPersist.Eof do
    begin
      VideoData.ID := qryPersist.FieldByName('id').AsString;
      VideoData.Description := qryPersist.FieldByName('description').AsString;
      VideoData.SizeInBytes := qryPersist.FieldByName('sizeinbytes').AsInteger;

      Result.Add(VideoData);

      qryPersist.Next;
    end;
  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

function TPersist.CreateServer(aServerData: TServerData): TServerData;
var
  NewGUID: string;
begin
  ConnectToDBFile;
  try
    NewGUID := GenerateGUID;

    qryPersist.SQL.Text := 'INSERT INTO server (id, name, ip, port)' +
                           ' VALUES (:id, :name, :ip, :port);';
    qryPersist.ParamByName('id').AsString := NewGUID;
    qryPersist.ParamByName('name').AsString := aServerData.Name;
    qryPersist.ParamByName('ip').AsString := aServerData.IP;
    qryPersist.ParamByName('port').AsInteger := aServerData.Port;

    qryPersist.ExecSQL;

    Result := aServerData;
    Result.ID := NewGUID;

  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

function TPersist.DeleteServer(aServerID: String): boolean;
begin
  ConnectToDBFile;
  try
    qryPersist.SQL.Text := 'DELETE FROM server WHERE id = :id;';
    qryPersist.ParamByName('id').AsString := aServerID;

    qryPersist.ExecSQL;

    Result := (qryPersist.RowsAffected > 0);
  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

function TPersist.DeleteVideo(aServerID, aVideoID: String): boolean;
begin
  ConnectToDBFile;
  try
    qryPersist.SQL.Text := 'DELETE FROM video WHERE id = :id and serverid = :serverid;';
    qryPersist.ParamByName('id').AsString := aVideoID;
    qryPersist.ParamByName('serverid').AsString := aServerID;

    qryPersist.ExecSQL;

    Result := (qryPersist.RowsAffected > 0);
  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

procedure TPersist.RecycleVideos(aDays: integer);
begin
  ConnectToDBFile;
  try
    qryPersist.SQL.Text := 'DELETE FROM video WHERE incdate <= date(''now'',''-' +
      IntToStr(aDays) + ' days'');';

    qryPersist.ExecSQL;
  finally
    qryPersist.Close;
    DisconnectFromDBFile;
  end;
end;

end.
