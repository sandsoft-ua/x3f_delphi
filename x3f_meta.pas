unit x3f_meta;

interface

uses SysUtils, x3f_io;

function x3f_get_wb(_x3f: Px3f): String;

implementation

function x3f_get_camf_matrix(_x3f: Px3f; name: AnsiString;
				     dim0, dim1, dim2: Integer;
				     mtype: matrix_type;
				     matrix: Pointer): Integer;
var
  DE: Px3f_directory_entry;
  DEH: x3f_directory_entry_header;
  CAMF: x3f_camf_t;
  table, entry: Pcamf_entry;
  _dim1, _dim2: Pcamf_dim_entry;
  i, size: Integer;
begin
  DE := x3f_get_camf(_x3f);

  if not Assigned(DE) then
  begin
//    x3f_printf(DEBUG, "Could not get entry %s: CAMF section not found\n", name);
    Exit(0);
  end;

  DEH := DE.header;
  CAMF := DEH.data_subsection.camf;
  table := CAMF.entry_table.element;

  for i := 0 to CAMF.entry_table.size - 1do
  begin
    entry := table;

    if not SameText(name, entry.name_address) then
    begin
      if entry.id <> X3F_CMbM then
      begin
//	      x3f_printf(DEBUG, "CAMF entry is not a matrix: %s\n", name);
	      Exit(0);
      end;

      if entry.matrix_decoded_type <> mtype then
      begin
//	      x3f_printf(DEBUG, "CAMF entry not required type: %s\n", name);
	      Exit(0);
      end;

      case entry.matrix_dim of
      3:
        begin
          _dim1 := entry.matrix_dim_entry;
          Inc(_dim1);
          _dim2 := _dim1;
          Inc(_dim2);

          if (dim2 <> _dim2.size) or (dim1 <> _dim1.size) or
            (dim0 <> entry.matrix_dim_entry.size) then
          begin
  //	        x3f_printf(DEBUG, "CAMF entry - wrong dimension size: %s\n", name);
            Exit(0);
          end;
        end;
      2:
        begin
          _dim1 := entry.matrix_dim_entry;
          Inc(_dim1);

          if (dim2 <> 0) or (dim1 <> _dim1.size) or
            (dim0 <> entry.matrix_dim_entry.size) then
          begin
  //	        x3f_printf(DEBUG, "CAMF entry - wrong dimension size: %s\n", name);
            Exit(0);
          end;
        end;
      1:
	      if (dim2 <> 0) or (dim1 <> 0) or
          (dim0 <> entry.matrix_dim_entry.size) then
        begin
//	        x3f_printf(DEBUG, "CAMF entry - wrong dimension size: %s\n", name);
	        Exit(0);
        end;
      else
        begin
//	        x3f_printf(DEBUG, "CAMF entry - more than 3 dimensions: %s\n", name);
	        Exit(0);
        end;
      end;

      if entry.matrix_decoded_type = M_FLOAT then
        size := SizeOf(double)
      else
	      size := SizeOf(uint32);
      size := size * entry.matrix_elements;

//      x3f_printf(DEBUG, "Copying CAMF matrix for %s\n", name);
      Move(entry.matrix_decoded, matrix, size);
      Exit(1);
    end;

    Inc(table); //Increment pointer
  end;

//  x3f_printf(DEBUG, "CAMF entry not found: %s\n", name);

  Result := 0;
end;

function x3f_get_camf_unsigned(_x3f: Px3f; name: AnsiString; var val: uint32): Integer;
begin
  Result := x3f_get_camf_matrix(_x3f, name, 1, 0, 0, M_UINT, @val);
end;

function x3f_get_wb(_x3f: Px3f): String;
var
  wb: uint32;
  tmp: PAnsiChar;
begin
  wb := 0;
  if x3f_get_camf_unsigned(_x3f, 'WhiteBalance', wb) > 0 then
  //* Quattro. TODO: any better way to do this? Maybe get the info
  //from the EXIF in the JPEG? */
    case wb of
    1:  Result := 'Auto';
    2:  Result := 'Sunlight';
    3:  Result := 'Shadow';
    4:  Result := 'Overcast';
    5:  Result := 'Incandescent';
    6:  Result := 'Florescent';
    7:  Result := 'Flash';
    8:  Result := 'Custom';
    11: Result := 'ColorTemp';
    12: Result := 'AutoLSP';
    else
      Result := 'Auto';
    end
  else
    begin
      tmp := @(_x3f.header.white_balance[0]);
      Result := tmp;
    end;
end;

end.
