package com.example.test1.mapper;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;

import com.example.test1.model.TBL_BOARD;
@Mapper
public interface BoardMapper {

	TBL_BOARD boardList(HashMap<String, Object> map);
	List<TBL_BOARD> boardList(HashMap<String, Object> map);
	
	
	
}
