package com.music.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PostCommentDTO {

    private String content;

    private Long postId;
}
