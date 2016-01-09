/******************************************************************************
 * FileName: add_funcs.h
 * Description: Do not sorted functions ROM-BIOS
 * Alternate SDK
 * Author: PV`
 * (c) PV` 2015
 *******************************************************************************/
#ifndef _INCLUDE_BIOS_ADD_FUNCS_H_
#  define _INCLUDE_BIOS_ADD_FUNCS_H_

int rom_get_power_db(void);
void rom_en_pwdet(int);
void rom_i2c_writeReg(uint32_t block, uint32_t host_id, uint32_t reg_add,
		      uint32_t data);
void rom_i2c_writeReg_Mask(uint32_t block, uint32_t host_id, uint32_t reg_add,
			   uint32_t Msb, uint32_t Lsb, uint32_t indata);
uint8_t rom_i2c_readReg_Mask(uint32_t block, uint32_t host_id, uint32_t reg_add,
			   uint32_t Msb, uint32_t Lsb);
uint8_t rom_i2c_readReg(uint32_t block, uint32_t host_id, uint32_t reg_add);


#endif /* _INCLUDE_BIOS_ADD_FUNCS_H_ */
