	pRegMaster: process(Clk, nReset) begin --defines the operations of the master interface unit
	-- update the read status signal after receiving proper AM_readDataValid
		if rising_edge(Clk) then
			if  inst_reg = "100" then --new read trigger is received	
				Read_next <= '1';
				AM_burstCount <= X"F0"; -- shouldn't be a problem to keep burstCount at a constant value during all operations
				AM_Adr <= addr_reg;		
			elsif AM_WaitRequest = '0' then -- Read cycle is allowed
				Read_next <= '0';
			end if;
			if AM_readDataValid = '1' then --valid data is present, FIFO transfer can be executed in parallel
				WrFIFO <= '1'; 
				FIFO_WrData <= AM_DataRead(15 downto 0);
				if AM_readCount = BURST_NUM then
					AM_readCount <= 0;
					AS_IRQ <= '1';
				else 
					AM_readCount <= AM_readCount+1;
					AS_IRQ <= '0';
				end if;			
			else
				if AM_readCount = BURST_NUM then
					AM_readCount <= 0;
					AS_IRQ <= '1';
				else
					AM_readCount <= AM_readCount;
					AS_IRQ <= '0';
				end if;	 
				WrFIFO <= '0'; 
				FIFO_WrData <= AM_DataRead(15 downto 0); --perhaps not necessary				
			end if;	
			-- if AM_readDataValid = '1' and AM_WaitRequest = '0' then -- Read cycle is allowed
				-- Read_next <= '0';
				-- WrFIFO <= '1'; 
				-- FIFO_WrData <= AM_DataRead;
			-- else 	
				-- Read_next <= '1';
			-- end if;
		end if;	
	end process pRegMaster;	
		
	