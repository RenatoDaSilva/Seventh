object Persist: TPersist
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object conPersist: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\borba\OneDrive\Documents\Embarcadero\Studio\Pr' +
        'ojects\Seventh\Win32\Debug\db_7th.sqlite'
      'DriverID=SQLite')
    Left = 48
    Top = 24
  end
  object qryPersist: TFDQuery
    Connection = conPersist
    Left = 176
    Top = 24
  end
end
