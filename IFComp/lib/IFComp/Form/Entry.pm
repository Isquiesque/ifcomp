package IFComp::Form::Entry;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

has '+enctype' => ( default => 'multipart/form-data');
has '+widget_wrapper' => (
    default => 'Bootstrap3',
);

has '+name' => ( default => 'entry' );
has '+html_prefix' => ( default => 1 );

use Readonly;
Readonly my $MAX_FILE_SIZE = 10485760;

use Try::Tiny;
use IFComp::Schema::Result::Entry;

has_field 'title' => (
    required => 1,
    type => 'Text',
);

has_field 'subtitle' => (
    type => 'Text',
);

has_field 'blurb' => (
    type => 'TextArea',
);

has_field 'pseudonym' => (
    type => 'Text',
    label => 'Your pseudonym (if using one for this entry)',
);

has_field 'reveal_pseudonym' => (
    default => 1,
    label => 'Reveal your identity after the comp ends (if using a pseuodym)?',
    type => 'Checkbox',
);

has_field 'email' => (
    type => 'Text',
    label => 'Contact email to display for this game',
);

has_field 'main_upload' => (
    type => 'Upload',
    label => 'Main game file',
    max_size => $MAX_FILE_SIZE,
);

has_field 'cover_upload' => (
    type => 'Upload',
    label => 'Cover art',
    max_size => $MAX_FILE_SIZE,
);

has_field 'walkthrough_upload' => (
    type => 'Upload',
    label => 'Main walkthrough or hint file',
    max_size => $MAX_FILE_SIZE,
);

has_field 'online_play_upload' => (
    type => 'Upload',
    label => 'Online play file (if different from main game file)',
    max_size => $MAX_FILE_SIZE,
);

has_field 'main_delete' => (
    type => 'Checkbox',
    label => 'Delete main game file',
);

has_field 'online_play_delete' => (
    type => 'Checkbox',
    label => 'Delete online-play file',
);

has_field 'walkthrough_delete' => (
    type => 'Checkbox',
    label => 'Delete walkthrough file',
);

has_field 'cover_delete' => (
    type => 'Checkbox',
    label => 'Delete cover art file',
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Submit game information',
    element_attr => {
        class => 'btn btn-success',
    },
);

sub validate_reveal_pseudonym {
    my $self = shift;
    my ( $field ) = @_;

    if ( $field->value && not $self->field( 'pseudonym' )->value ) {
        $field->add_error( "This setting makes sense only if you're setting "
                           . "a pseudonym." );
    }
}

sub validate_cover_upload {
    my $self = shift;
    my ( $field ) = @_;

    if ( $field->value && not $field->value->filename =~ /\.png$/ ) {
        $field->add_error( "This doesn't appear to be a .png file.");
    }
}

sub validate_title {
    my $self = shift;
    my ( $field ) = @_;

    try {
        if ( $self->item->id ) {
            IFComp::Schema->test_titles_for_oversimilarity(
                $field->value,
                $self->item->title,
            );
        }
        else {
            IFComp::Schema->test_titles_for_oversimilarity(
                $field->value,
            );
        }
    }
    catch {
        $field->add_error( "This title is too similar to another entry's title: $_");
    };
}

1;
