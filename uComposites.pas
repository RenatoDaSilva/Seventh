unit uComposites;

interface

type
  TResponse = record
    JSON: string;
    Status: integer;
end;

  TServerData = record
    ID: string;
    Name: string;
    IP: string;
    Port: integer;
  end;

  TVideoData = record
    ID: string;
    ServerID: string;
    Description: string;
    VideoContent: string;
    SizeInBytes: integer;
  end;

implementation

end.