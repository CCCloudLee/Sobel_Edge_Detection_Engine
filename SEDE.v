module SEDE ( input clk,
			        input rst,
			        input [7:0] pix_data,
			        output reg valid,
			        output reg [7:0] edge_out,
			        output reg busy );

reg unsigned [7:0] picture [0:31][0:31];
integer i, j, count, xin, yin, xout, yout, Gx, Gy, out;

  always @ ( posedge rst ) begin
    if ( rst ) begin
      valid <= 0;
      edge_out <= 0;
      busy <= 0;
      for ( i=0; i<=31; i=i+1 ) begin
        for ( j=0; j<=31; j=j+1 ) begin
            picture[i][j] = 0;
        end
      end
      count <= 0;
      xin <= 0;
      yin <= 0;
      xout <= 0;
      yout <= 0;
      Gx <= 0;
      Gy <= 0;
      out <= 0;
    end
  end

  always @ ( posedge clk or posedge rst ) begin
    if ( (~rst) && ( pix_data[0] !== 1'bz ) ) begin
      picture[xin][yin] = pix_data;
    end
  end
  
  always @ ( posedge clk or posedge rst ) begin
    if ( (~rst) && ( pix_data[0] !== 1'bz ) ) begin
      count <= count + 1;
    end
  end
  
  always @ ( posedge clk or posedge rst ) begin
    if ( (~rst) && ( pix_data[0] !== 1'bz ) ) begin
      if ( count >= 1024 ) begin
        xin <= 0;
        yin <= 0;
      end
      else if ( xin == 31 ) begin
        xin <= 0;
        yin <= yin + 1;
      end
      else begin
        xin <= xin + 1;
      end
    end
  end
  
  always @ ( posedge clk or posedge rst ) begin
    if ( (~rst) && ( pix_data[0] !== 1'bz ) ) begin
      if ( count >= 1057 ) begin
        valid <= 0;
        xout <= 0;
        yout <= 0;
      end
      else if ( (count >= 33) && (count <= 65) ) begin
        valid <= 0;
      end
      else if ( xout == 31 ) begin
        valid <= 1;
        xout <= 0; 
        yout <= yout + 1;
      end
      else begin
        valid <= 1;
        xout <= xout + 1;
      end
    end
  end
  
  always @ ( posedge clk or posedge rst ) begin
    if ( (~rst) && ( pix_data[0] !== 1'bz ) ) begin
      if ( xout == 0 || yout == 0 || xout == 31 || yout == 31 ) begin
        edge_out <= 0;
      end
      else if ( (count >= 33) && (count <= 65) ) begin
        edge_out <= 0;
      end
      else if ( count >= 1057 ) begin
        edge_out <= 0;
      end
      else begin
        Gx = picture[xout-1][yout-1] + picture[xout-1][yout] * 2 + picture[xout-1][yout+1] - picture[xout+1][yout-1] - picture[xout+1][yout] * 2 - picture[xout+1][yout+1];
        Gy = picture[xout-1][yout-1] + picture[xout][yout-1] * 2 + picture[xout+1][yout-1] - picture[xout-1][yout+1] - picture[xout][yout+1] * 2 - picture[xout+1][yout+1];
        out = ( Gx + Gy ) / 2;
        if ( out < 0 )  edge_out <= 0;
        else if ( out > 255 ) edge_out <= 255;
        else  edge_out <= out;
      end
    end
  end
  
endmodule
